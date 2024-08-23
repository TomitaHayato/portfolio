class ApplicationController < ActionController::Base
  before_action :require_login
  before_action :playing_task_sesison_reset

  private

  def not_authenticated
    flash[:alert] = 'ログインしてください'
    redirect_to login_path
  end

  def playing_task_sesison_reset
    session[:playing_task_num] = nil if session[:playing_task_num]
  end
end
