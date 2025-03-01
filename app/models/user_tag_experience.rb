class UserTagExperience < ApplicationRecord
  belongs_to :user
  belongs_to :tag

  validates :experience_point, presence: true

  scope :recent_one_month, -> { where(created_at: 1.month.ago..) }
  scope :recent_one_week , -> { where(created_at: 1.week.ago..)  }
  # 指定した週に作成されたデータ
  scope :weekly, ->(now) { where(created_at: now.all_week) }

  # ユーザーの合計expを算出。selfにはuser.user_tag_experiencesを想定
  def self.total_experience_points
    sum('experience_point')
  end

  # { tag.name: exp }の形式のハッシュを作成
  def self.make_tag_point_hash(empty_exp_hash)
    tag_point_hash = empty_exp_hash.dup # 浅いコピー

    find_each do |user_tag_experience|
      tag_name                  = user_tag_experience.tag.name
      tag_point_hash[tag_name] += user_tag_experience.experience_point
    end

    tag_point_hash.sort_by { |_, val| -val }.to_h
  end
end
