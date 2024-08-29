class Routine < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 500 }

  scope :posted, -> { where(is_posted: true) }

  def reset_status
    self.is_active = false
    self.is_posted = false
    self.copied_count = 0
    self.completed_count = 0
    return self
  end

  def all_task_estimated_time
    total_estimated_time_in_second = 0
    if self.tasks.present?
      self.tasks.each do |task|
        total_estimated_time_in_second += task.estimated_time_in_second
      end
    end
    total_estimated_time_in_second
    # second_to_time_string(total_estimated_time_in_second)
  end

  private

  def second_to_time_string(time_in_second)
    hour = time_in_second / 3600
    time_in_second -= hour * 3600
    minute = time_in_second / 60
    time_in_second -= minute * 60
    second = time_in_second
    { hour: hour, minute: minute, second: second }
  end
end
