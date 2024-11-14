require 'securerandom'
require 'digest'
require 'net/http'
require 'json'

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
        # providerから取得した情報でユーザーを新規作成する
        @user = create_from(provider) # lineの場合、emailはuserIdのまま

        # lineの場合、emailを変更する処理を実行
        if provider == 'line'
          id_token   = @access_token[:id_token]
          uid        = @user_hash[:uid]
          line_email = get_email_from_line(id_token, uid)
          
          update_user_email(line_email)
        end
        
        reset_session
        auto_login(@user)
        redirect_to my_pages_path, :notice => "ログインしました！"
      rescue
        redirect_to root_path, :alert => "#{provider.titleize}でのログインに失敗しました。"
      end
    end
  end
  
  private

  def auth_params
    params.permit(:code, :provider, :error, :state, :friendship_status_changed)
  end

  # Lineのid_tokenの検証を行い、レスポンスを受け取る
  def get_email_from_line(id_token, uid)
    uri  = URI.parse('https://api.line.me/oauth2/v2.1/verify')
    head = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    body = [
             ['id_token' , id_token],
             ['client_id', Rails.application.credentials.dig(:line, :login_channel_id)],
             ['user_id'  , uid]
           ]
    # POSTリクエストを作成
    req              = Net::HTTP::Post.new(uri.path, head)
    req.body         = URI.encode_www_form(body)
    # HTTPオブジェクトを作成
    http             = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    # リクエストを送信し、レスポンスを取得
    response = http.start { |http|
      http.request(req)     
    }
    
    response_body = JSON.parse(response.body)
    email         = response_body['email']
  end

  def update_user_email(email = nil)
    if email
      @user.email = email
    else
      @user.email = "morning-#{@user.id}@email.com"
    end

    @user.save!
  end
end