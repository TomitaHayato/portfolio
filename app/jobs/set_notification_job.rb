class SetNotificationJob < ApplicationJob
  queue_as :default

  def perform()
    time_now = Time.current
    User.includes(:routines, :authentications).each do |user|
      user_line_authentication = user.authentications.find_by(provider: 'line', user_id: user.id)
      next unless user_line_authentication # UserがLineを介して登録していない場合はスキップ

      uid = user_line_authentication.uid
      active_routine = user.routines.find_by(is_active: true)
      perform_line_notification_job(active_routine, uid, time_now) if active_routine
    end
  end

  private

  # 現在時刻がルーティン開始時間と一致する場合、LineNotificationJobを実行する
  def perform_line_notification_job(routine, uid, time_now)
    if routine.start_time.strftime('%H:%M') == time_now.strftime('%H:%M')
      LineNotificationJob.perform_later(uid)
      p "--------------- LineNotificationJob [ 呼び出し ] --------------"
    end
  end
end
