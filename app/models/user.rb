class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :routines, dependent: :destroy
  has_many :user_tag_experiences, dependent: :destroy
  has_many :tags, through: :user_tag_experiences
  has_many :likes, dependent: :destroy
  has_many :liked_routines, through: :likes, source: :routine

  validates :password, length: { minimum: 4 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  enum role: { admin: 0, general: 1 }
end
