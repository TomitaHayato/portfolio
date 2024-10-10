class Admin::DashboardController < Admin::BaseController
  def index
    @reward = Reward.all
  end
end
