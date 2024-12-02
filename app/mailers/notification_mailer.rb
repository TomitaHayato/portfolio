#TODO: メールのViewを追加
class NotificationMailer < ApplicationMailer
  # 呼び出し：NotifcationMailer.with(user: user).notify_start.deliver_later
  def notify_email
    # ユーザーを取得=>ユーザーのemailにマイページへのURLを載せる
    @user = params[:user]
    @url  = my_pages_url
    mail(to:      @user.email,
         subject: "[Morning Forest] ルーティン開始通知"    
    )
  end
end
