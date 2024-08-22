class Routine < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 500 }

  scope :posted, -> { where(is_posted: true) }
end
