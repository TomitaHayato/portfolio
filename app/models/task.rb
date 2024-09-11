class Task < ApplicationRecord
  belongs_to :routine
  has_many :tags, through: :task_tags
  has_many :task_tags, dependent: :destroy

  acts_as_list scope: :routine

  validates :title, presence: true, length: { maximum: 25 }
  validates :estimated_time_in_second,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      message: 'は1以上の整数を入力してください'
    }

  def estimated_time
    result = second_to_time_string(estimated_time_in_second)
    result[:hour] = "0#{result[:hour]}" if result[:hour] < 10
    result[:minute] = "0#{result[:minute]}" if result[:minute] < 10
    result[:second] = "0#{result[:second]}" if result[:second] < 10
    result
  end

  private

  def second_to_time_string(time_in_second)
    hour = time_in_second / 3600
    time_in_second -= hour * 3600
    minute = time_in_second / 60
    time_in_second -= minute * 60
    second = time_in_second
    { hour:, minute:, second: }
  end
end
