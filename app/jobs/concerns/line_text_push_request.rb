require 'active_support'
require 'net/http'
require 'uri'
require 'json'

module LineTextPushRequest
  extend ActiveSupport::Concern

  # LINE Push通知のエンドポイントにPOSTリクエストを送信し、レスポンスを取得
  def request_line_push_end_point(uid, text)
    # エンドポイントへのPOSTリクエストを作成
    uri = URI.parse('https://api.line.me/v2/bot/message/push')
    req = Net::HTTP::Post.new(uri)
    # リクエストヘッダの作成
    req.content_type     = 'application/json'
    req['Authorization'] = "Bearer #{Rails.application.credentials.channel_token}"
    # リクエストボディの作成
    req.body = make_request_body_json(uid, text)
    # エンドポイントにrequestを送信（返り値はレスポンス）
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
  end

  private

  # リクエストボディの情報を作成
  def make_request_body_json(uid, text)
    body_hash = {
                  to:       uid,
                  messages: [type: 'text', text: text]
                }

    JSON.generate(body_hash)
  end
end
