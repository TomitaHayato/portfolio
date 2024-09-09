class LineNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
    uri = URI.parse(Rails.application.routes.url_helpers.root_url)
    # GETリクエストを送信
    response = Net::HTTP.get_response(uri)
  end
end
