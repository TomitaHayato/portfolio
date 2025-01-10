class WeeklyReportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false # Jobが失敗した際、再試行せず破棄

  def perform
    now = Time.current

    begin
      User.not_off.general.includes(:authentications, :user_tag_experiences, :achieve_records).find_each do |user|
        if user.line?
          next unless user.link_line? # UserがLineを介して登録していない場合はスキップ

          LineWeeklyReportJob.perform_later(user, now)
        elsif user.email?
          WeeklyReportMailer.with(user:, now:).notify_email.deliver_later
        end
      end
    rescue StandardError => e
      Rails.logger.error("週間レポートJobは失敗しました。エラー: #{e.message}")
    end
  end
end
