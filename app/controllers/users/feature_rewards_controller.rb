class Users::FeatureRewardsController < ApplicationController
  def update
    reward_id = user_params[:feature_reward_id].to_i
    if current_user.reward_ids.include?(reward_id) && current_user.feature_reward_id != reward_id
      current_user.update!(user_params)
      flash.now[:notice] = '称号をプロフィールに設定しました'
    end

    @rewards        = Reward.includes(:users)
    @feature_reward = current_user.feature_reward
  end

  private

  def user_params
    params.require(:user).permit(:feature_reward_id)
  end
end
