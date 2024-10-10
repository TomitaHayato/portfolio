class Admin::UserSessionsController < Admin::BaseController
  skip_before_action :require_login
  skip_before_action :check_admin

  def new; end

  def create
    @user = login(params[:email], params[:password])
    if @user
      redirect_to admin_root_path
    else
      render :new
    end
  end
end
