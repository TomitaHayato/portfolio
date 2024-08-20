class Task < ApplicationRecord
  belongs_to :routine

  validates :title, presence: true, length: { maximun: 50 }
  validates :estimated_time_in_second, presence: true
end
