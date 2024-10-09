class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :routines, dependent: :destroy
  has_many :user_tag_experiences, dependent: :destroy
  has_many :tags, through: :user_tag_experiences
  has_many :likes, dependent: :destroy
  has_many :liked_routines, through: :likes, source: :routine
  has_many :authentications, :dependent => :destroy
  has_many :user_rewards, dependent: :destroy
  has_many :rewards, through: :user_rewards
  accepts_nested_attributes_for :authentications

  validates :password, length: { minimum: 4 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :reset_password_token, uniqueness: true, allow_nil: true

  enum role: { admin: 0, general: 1 }
end
