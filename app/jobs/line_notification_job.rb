require 'net/http'
require 'uri'
require 'json'

class LineNotificationJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false # Jobが失敗した際、再試行せず破棄
  include Rails.application.routes.url_helpers

  def perform(uid)
    post_response_from_end_point(uid)
  end

  private

  # LINEプロバイダーのエンドポイントにPOSTリクエストを送信し、レスポンスを取得する
  def post_response_from_end_point(uid)
    # エンドポイントへのPOSTリクエストを作成
    uri     = URI.parse('https://api.line.me/v2/bot/message/push')
    request = Net::HTTP::Post.new(uri)
    # リクエストヘッダ・ボディを作成
    request.content_type     = 'application/json'
    request['Authorization'] = "Bearer #{Rails.application.credentials.channel_token}"
    body_hash = {
      to: uid,
      messages: [
        type: 'text',
        text: "おはようございます！\n今日もモーニングルーティンを実践しましょう！！\n#{auth_at_provider_url(provider: :line, host: Settings.url.host)}"
      ]
    }
    request.body = JSON.generate(body_hash)

    # エンドポイントにrequestを送信
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end
end
