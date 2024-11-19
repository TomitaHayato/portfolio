class UserTagExperience < ApplicationRecord
  belongs_to :user
  belongs_to :tag

  validates :experience_point, presence: true

  scope :recent_one_month, -> { where("created_at >= ?", 1.month.ago) }
  scope :recent_one_week,  -> { where("created_at >= ?", 1.week.ago)  }

  # ユーザーの合計expを算出。selfにはuser.user_tag_experiencesを想定
  def self.total_experience_points
    sum('experience_point')
  end
end
