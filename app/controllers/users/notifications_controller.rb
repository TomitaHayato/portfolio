class Users::NotificationsController < ApplicationController
  def update
    current_user.update!(user_params)
  end

  private

  def user_params
    # userがLine連携していない場合は、line通知に設定できないようにする
    params[:user][:notification] = 'email' if params[:user][:notification] == 'line' && !current_user.link_line?

    params.require(:user).permit(:notification)
  end
end
