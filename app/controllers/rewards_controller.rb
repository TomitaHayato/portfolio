class RewardsController < ApplicationController
  def index
    @rewards = Reward.includes(:users)
  end
end
