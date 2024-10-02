class SetNotificationJob < ApplicationJob
  queue_as :default

  def perform()
    time_now = Time.current
    User.includes(:routines).each do |user|
      active_routine = user.routines.find_by(is_active: true)
      perform_line_notification_job(active_routine, user, time_now) if active_routine
    end
  end

  private

  def perform_line_notification_job(routine, user, time_now)
    if routine.start_time.strftime('%H:%M') == time_now.strftime('%H:%M')
      p "#{routine}は#{user.name}のルーティン"
      LineNotificationJob.perform_later(user.id)
    end
  end
end
