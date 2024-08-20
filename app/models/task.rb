class Task < ApplicationRecord
  belongs_to :routine
  acts_as_list scope: :routine

  validates :title, presence: true, length: { maximum: 50 }
  validates :estimated_time_in_second, presence: true
end
