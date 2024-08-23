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
end
