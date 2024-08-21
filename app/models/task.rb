class Task < ApplicationRecord
  belongs_to :routine
  acts_as_list scope: :routine

  validates :title, presence: true, length: { maximum: 50 }
  validates :estimated_time_in_second, presence: true

  def estimated_time
    result = Hash.new
    value = estimated_time_in_second

    result[:hour] = value / 3600
    value -= result[:hour] * 3600
    result[:minute] = value / 60
    value -= result[:minute] * 60
    result[:second] = value

    return result
  end
end
