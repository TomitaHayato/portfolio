class RewardsController < ApplicationController
  def index
    @rewards        = Reward.includes(:users)
    @feature_reward = current_user.feature_reward
  end
end
