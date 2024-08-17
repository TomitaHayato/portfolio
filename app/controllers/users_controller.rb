class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[ new create ]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_new_params)
    @user.role = "general"
    @user.complete_routines_count = 0

    if @user.save
      flash[:notice] = "ユーザーを新しく追加しました"
      redirect_to login_path
    else
      flash.now[:alert] = "ユーザーの作成に失敗しました"
      render :new
    end
  end

  private

  def user_new_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
