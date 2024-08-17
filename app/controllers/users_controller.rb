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

  def show; end

  def edit
    @user = User.find(current_user.id)
  end

  def update
    @user = User.find(current_user.id)
    if @user.update(user_edit_params)
      flash[:notice] = "プロフィールを更新しました"
      redirect_to user_path(current_user)
    else
      render :edit
    end
  end

  private

  def user_new_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_edit_params
    params.require(:user).permit(:name, :email)
  end
end
