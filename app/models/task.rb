class Task < ApplicationRecord
  belongs_to :routine
  acts_as_list scope: :routine

  validates :title, presence: true, length: { maximum: 50 }
  validates :estimated_time_in_second, presence: true

  def estimated_time
    result = second_to_time_string(estimated_time_in_second)
    result[:hour] = "0#{result[:hour]}" if result[:hour] < 10
    result[:minute] = "0#{result[:minute]}" if result[:minute] < 10
    result[:second] = "0#{result[:second]}" if result[:second] < 10
    return result
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
