class Routine < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 500 }
end
