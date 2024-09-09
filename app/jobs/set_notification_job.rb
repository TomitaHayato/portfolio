class SetNotificationJob < ApplicationJob
  queue_as :default

  def perform()
    # Do something later
    User.includes(:routines).each do |user|
      active_routine = user.routines.find_by(is_active: true)
      p "#{active_routine}は#{user.name}のルーティン"
      perform_line_notification_job(active_routine, user) if active_routine
    end
  end

  private

  def perform_line_notification_job(routine, user)
    if routine.start_time.strftime('%H:%M') == Time.current.strftime('%H:%M')
      LineNotificationJob.perform_later(user.id)
    end
  end
end
