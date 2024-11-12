require 'securerandom'
require 'digest'

class OauthsController < ApplicationController
  skip_before_action :require_login, raise: false
      
  def oauth
    login_at(auth_params[:provider])
  end
      
  def callback
    provider = auth_params[:provider]

    if @user = login_from(provider)
      redirect_to root_path, :notice => "ログインしました！"
    else
      begin
        # LINEから取得した情報でユーザーを新規作成する
        @user = create_from(provider)

        reset_session
        auto_login(@user)
        redirect_to my_pages_path, :notice => "ログインしました！"
      rescue
        redirect_to root_path, :alert => "Failed to login from #{provider.titleize}!"
      end
    end
  end
  
  private

  def auth_params
    params.permit(:code, :provider, :error, :state, :friendship_status_changed)
  end
end