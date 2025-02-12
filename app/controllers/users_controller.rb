class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new  create]
  before_action      :guest_block  , only: %i[edit update]

  def show
    @achieve_records = current_user.achieve_records.weekly(Time.current).includes(routine: :tasks)
    @routine_ids     = current_user.routine_ids
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(current_user.id)
  end

  def create
    @user = User.new(user_new_params)
    if @user.save
      # ユーザーの初期設定を行う
      @user.make_first_routine
      @user.create_quick_routine_template!

      auto_login(@user)
      redirect_to my_pages_path, notice: 'ユーザーを新しく追加しました'
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
