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
    session[:playing_task_num] = nil if session[:playing_task_num]
    session[:experiene_log]    = nil if session[:experiene_log]
  end

  def guest_block
    if current_user.guest?
      respond_to do |format|
        format.html { 
          flash[:danger] = 'ゲストユーザー様はご利用できません'
          redirect_to request.referer || my_pages_path 
        }

        format.turbo_stream {
          flash.now[:danger] = 'ゲストユーザー様はご利用できません'
          render turbo_stream: [
            turbo_stream.update('flash', partial: 'shared/flash')
          ]
        }
      end
    end
  end
end
