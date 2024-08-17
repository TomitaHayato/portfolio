class Routine < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maxmum: 500 }
end
