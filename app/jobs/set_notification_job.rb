class SetNotificationJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false # Jobが失敗した際、再試行せず破棄

  # 全てのLINE登録済みユーザーに対し、ルーティンの開始時間にLINE Push通知を送信するJobを呼び出す
  def perform
    time_now = Time.current
    begin
      User.not_off.general.includes(:authentications).find_each do |user|
        active_routine = user.routines.find_by(is_active: true)

        next if active_routine.nil? || !start_time?(active_routine.start_time, time_now)

        case user.notification
        when 'line'
          next unless user.link_line? # UserがLineを介して登録していない場合はスキップ

          LineNotificationJob.perform_later(user)
        when 'email'
          NotificationMailer.with(user:).notify_email.deliver_later
        end
      end
    rescue StandardError => e
      Rails.logger.error("通知Jobは失敗しました。エラー: #{e.message}")
    end
  end

  private

  def start_time?(start_time, time_now)
    start_time.strftime('%H:%M') == time_now.strftime('%H:%M')
  end
end
