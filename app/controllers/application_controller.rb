class ApplicationController < ActionController::Base
  before_action :require_login
  before_action :playing_task_sesison_reset

  private

  def not_authenticated
    flash[:alert] = 'ログインしてください'
    redirect_to login_path
  end

  # routines/playsコントローラで生成したsessionを削除
  def playing_task_sesison_reset
    session[:task_index] = nil if session[:task_index]
    session[:exp_log]    = nil if session[:exp_log]
  end

  def guest_block
    return unless current_user.guest?

    respond_to do |format|
      format.html do
        flash[:danger] = 'ゲストユーザー様はご利用できません'
        redirect_to request.referer || my_pages_path
      end

      format.turbo_stream do
        flash.now[:danger] = 'ゲストユーザー様はご利用できません'
        render turbo_stream: [
          turbo_stream.update('flash', partial: 'shared/flash')
        ]
      end
    end
  end
end
