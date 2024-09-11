class LinebotsController < ApplicationController
  protect_from_forgery except: :create
  skip_before_action :require_login

  def create
    client = Line::Bot::Client.new do |config|
      config.channel_id = Rails.application.credentials.channel_id
      config.channel_secret = Rails.application.credentials.channel_secret
      config.channel_token = Rails.application.credentials.channel_token
    end

    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    return head :bad_request unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)
    events.each do |event|
      message = case event
                when Line::Bot::Event::Message
                  { type: 'text', text: parse_message_type(event) }
                else
                  { type: 'text', text: '........' }
                end
      client.reply_message(event['replyToken'], message)
    end
    head :ok
  end

  private

  def parse_message_type(event)
    case event.type
    when Line::Bot::Event::MessageType::Text
      "ルーティンを始めましょう！ #{my_pages_url}" # ユーザーが投稿したものがテキストメッセージだった場合に返す値
    else
      'Thanks!!' # ユーザーが投稿したものがテキストメッセージ以外だった場合に返す値
    end
  end
end
