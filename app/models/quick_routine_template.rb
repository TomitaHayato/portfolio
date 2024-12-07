class QuickRoutineTemplate < ApplicationRecord
  belongs_to :user

  validates :title      , length: { maximum: 25  }, presence: true
  validates :description, length: { maximum: 500 }
end
