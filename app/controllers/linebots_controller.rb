class LinebotsController < ApplicationController
  protect_from_forgery except: :callback
  skip_before_action :require_login

  def callback
    client = Line::Bot::Client.new do |config|
      config.channel_id     = Rails.application.credentials.channel_id
      config.channel_secret = Rails.application.credentials.channel_secret
      config.channel_token  = Rails.application.credentials.channel_token
    end

    body      = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    return head :bad_request unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)
    events.each do |event|
      message = case event
                when Line::Bot::Event::Message
                  { type: 'text', text: parse_message_type(event) }
                else
                  { type: 'text', text: '\(^ ^)/' }
                end
      client.reply_message(event['replyToken'], message)
    end
    head :ok
  end

  private

  # ユーザーがテキストメッセージを送信した場合のみ、応答を返す
  def parse_message_type(event)
    return '\(^ ^)/' unless event.type == Line::Bot::Event::MessageType::Text

    "メッセージをありがとう！！\nルーティン開始時間になったら通知を送るよ！\n#{my_pages_url}"
  end
end
