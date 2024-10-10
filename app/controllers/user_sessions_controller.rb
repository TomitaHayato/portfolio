class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new; end

  def create
    @user = login(params[:email], params[:password])
    if @user
      flash[:notice] = 'ログインしました！'
      redirect_to my_pages_path
    else
      render :new
    end
  end

  def destroy
    user = current_user
    logout
    user.destroy! if user.role == "guest"

    flash[:notice] = 'ログアウトしました。'
    redirect_to root_path
  end
end
