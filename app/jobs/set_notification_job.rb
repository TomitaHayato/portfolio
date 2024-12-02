# TODO: メールでも通知できるようにJobを追加
class SetNotificationJob < ApplicationJob
  queue_as :default

  # 全てのLINE登録済みユーザーに対し、ルーティンの開始時間にLINE Push通知を送信するJobを呼び出す
  def perform()
    time_now = Time.current
    
    User.includes(:authentications).each do |user|
      active_routine = user.routines.find_by(is_active: true)
      next unless active_routine

      case user.notification
      when 'off'
        next
      when 'line'
        next unless user.link_line? # UserがLineを介して登録していない場合はスキップ

        user_line_authentication = user.authentications.find_by(provider: 'line', user_id: user.id)
        uid                      = user_line_authentication.uid

        # 開始時間なら、Line通知ジョブを呼び出し
        LineNotificationJob.perform_later(uid) if start_time?(active_routine.start_time, time_now)
      when 'email'
        if start_time?(active_routine.start_time, time_now)
          NotificationMailer.with(user: user).notify_email.deliver_later
        end
      end
    end
  end

  private

  def start_time?(start_time, time_now)
    start_time.strftime('%H:%M') == time_now.strftime('%H:%M')
  end
end
