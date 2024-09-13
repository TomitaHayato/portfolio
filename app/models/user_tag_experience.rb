class UserTagExperience < ApplicationRecord
  belongs_to :user
  belongs_to :tag

  validates :experience_point, presence: true
end
