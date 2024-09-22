class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def show; end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(current_user.id)
  end

  def create
    @user = User.new(user_new_params)
    if @user.save
      auto_login(@user)
      flash[:notice] = 'ユーザーを新しく追加しました'
      redirect_to my_pages_path
    else
      flash.now[:alert] = 'ユーザーの作成に失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_edit_params)
      flash[:notice] = 'プロフィールを更新しました'
      redirect_to user_path(current_user)
    else
      render :edit, status: :unprocessable_entity
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
