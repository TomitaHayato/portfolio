class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new  create]
  before_action      :guest_block  , only: %i[edit update]

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
      @user.make_first_routine.make_first_task
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
    params.require(:user).permit(:name, :email, :avatar, :avatar_cache)
  end
end
