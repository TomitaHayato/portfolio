class Reward < ApplicationRecord
  has_many :user_rewards, dependent: :destroy
  has_many :users, through: :user_rewards

  validates :name, presence: true
  validates :condition, presence: true
end
