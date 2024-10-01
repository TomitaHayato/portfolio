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
      redirect_to user_path(@user), :notice => "ログインしました！ メールアドレスの編集を行なってください"
    else
      begin
        @user = create_from(provider)

        # create_fromの時点では、emailカラムにLINEのuserIdが格納されている。
        # 以下の処理でメールアドレスからLINEのuserIdが推測されないようにする。
        unique_email = generate_unique_email_address(@user.email)
        @user.update!(email: "#{unique_email}@email")

        reset_session
        auto_login(@user)
        redirect_to user_path(@user), :notice => "ログインしました！ メールアドレスの編集を行なってください"
      rescue
        redirect_to root_path, :alert => "Failed to login from #{provider.titleize}!"
      end
    end
  end
  
  private

  def auth_params
    params.permit(:code, :provider, :error, :state, :friendship_status_changed)
  end

  # 引数に渡した文字列からハッシュ値を生成する
  def generate_digest_hash(letter)
    Digest::SHA256.hexdigest(letter)
  end

  # 渡されたメールアドレスから、一意のメールアドレスを生成する
  def generate_unique_email_address(email_address)
    generate_digest_hash(email_address) + SecureRandom.uuid
  end
end