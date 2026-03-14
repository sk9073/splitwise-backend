module Api
  module V1
    class UsersController < ApplicationController
      def create
        token = request.headers['Authorization']&.split(' ')&.last
        if token.blank?
          return render json: { error: 'Missing token' }, status: :unauthorized
        end

        begin
          project_id = ENV.fetch('FIREBASE_PROJECT_ID', 'dup-splitwise')
          verifier = FirebaseTokenVerifier.new(project_id)
          payload = verifier.decode(token)
          
          firebase_uid = payload['sub']
          email = payload['email']
          name = payload['name'] || email.split('@').first
          avatar_url = payload['picture']

          user = User.find_or_initialize_by(firebase_uid: firebase_uid)
          user.assign_attributes(
            email: email,
            name: name,
            avatar_url: avatar_url
          )

          if user.save
            render json: { user: user }, status: :ok
          else
            render json: { error: user.errors.full_messages }, status: :unprocessable_entity
          end
        rescue StandardError => e
          render json: { error: e.message }, status: :unauthorized
        end
      end
    end
  end
end
