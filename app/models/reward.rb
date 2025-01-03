class Reward < ApplicationRecord
  mount_uploader :image, RewardImageUploader

  has_many :user_rewards   , dependent: :destroy
  has_many :users          , through:   :user_rewards
  has_many :featuring_users, dependent: :nullify     , class_name: 'User', foreign_key: 'feature_reward_id', inverse_of: 'feature_reward'

  validates :name     , presence: true
  validates :condition, presence: true

  scope :for_user,     ->(user_id) { joins(:user_rewards).where(user_rewards: { user_id: }) }
  scope :not_for_user, ->(user)    { where.not(id: user.reward_ids) }
end
