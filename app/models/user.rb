# == Schema Information
#
# Table name: users
#
#  id           :uuid             not null, primary key
#  firebase_uid :string           not null
#  email        :string           not null
#  name         :string
#  avatar_url   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class User < ApplicationRecord
  validates :firebase_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  # Ensure ID is a UUID (Rails handles this if the table is created with id: :uuid)
end
