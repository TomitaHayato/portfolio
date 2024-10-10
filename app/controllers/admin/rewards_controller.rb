class Admin::RewardsController < Admin::BaseController
  def index
    @rewards = Reward.all
  end

  def edit
    @reward = Reward.find(params[:id])
  end

  def update
    @reward = Reward.find(params[:id])
    if @reward.update(reward_params)
      flash[:notice] = "更新しました"
      redirect_to admin_rewards_path
    else
      render :edit
    end
  end

  private

  def reward_params
    params.require(:reward).permit(:name, :image, :image_cache, :description)
  end
end
