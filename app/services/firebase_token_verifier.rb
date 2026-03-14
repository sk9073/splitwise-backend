require 'jwt'
require 'net/http'

class FirebaseTokenVerifier
  ALGORITHM = 'RS256'.freeze
  ISSUER_PREFIX = 'https://securetoken.google.com/'.freeze
  CERT_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'.freeze

  def initialize(firebase_project_id)
    @project_id = firebase_project_id
  end

  def decode(token)
    # Support Firebase Auth Emulator in development
    if ENV['FIREBASE_AUTH_EMULATOR_HOST'].present?
      payload, _header = JWT.decode(token, nil, false)
      return payload
    end

    header = decode_header(token)
    kid = header['kid']
    public_key = fetch_public_keys[kid]

    raise 'Invalid Firebase ID token: missing kid' unless kid
    raise 'Invalid Firebase ID token: public key not found' unless public_key

    payload, _header = JWT.decode(
      token,
      OpenSSL::X509::Certificate.new(public_key).public_key,
      true,
      {
        algorithm: ALGORITHM,
        verify_iat: true,
        verify_aud: true,
        aud: @project_id,
        verify_iss: true,
        iss: "#{ISSUER_PREFIX}#{@project_id}"
      }
    )

    payload
  rescue JWT::ExpiredSignature
    raise 'Firebase ID token has expired'
  rescue JWT::InvalidIatError
    raise 'Firebase ID token issued in the future'
  rescue JWT::InvalidAudError
    raise 'Firebase ID token has invalid audience'
  rescue JWT::InvalidIssuerError
    raise 'Firebase ID token has invalid issuer'
  rescue StandardError => e
    raise "Firebase ID token verification failed: #{e.message}"
  end

  private

  def decode_header(token)
    JWT.decode(token, nil, false).last
  end

  def fetch_public_keys
    # Use a simple cache or just fetch every time for now (ideally cache this)
    @public_keys ||= begin
      response = Net::HTTP.get_response(URI(CERT_URL))
      JSON.parse(response.body)
    end
  end
end
