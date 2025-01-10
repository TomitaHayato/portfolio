class LineNotificationJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false # Jobが失敗した際、再試行せず破棄
  include Rails.application.routes.url_helpers
  include LineTextPushRequest

  def perform(user)
    # 通知するText
    text = "おはようございます！\n
            今日もモーニングルーティンを実践しましょう！！\n\n
            #{auth_at_provider_url(provider: :line, host: Settings.url.host)}"

    uid  = user.authentications.find_by(provider: 'line').uid

    # プッシュ通知を送信
    request_line_push_end_point(uid, text)
  end
end
