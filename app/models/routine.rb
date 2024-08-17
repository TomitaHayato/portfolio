class Routine < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maxmum: 255 }
  validates :description, length: { maxmum: 500 }
end
