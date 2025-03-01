class AchieveRecord < ApplicationRecord
  belongs_to :user
  belongs_to :routine, optional: true

  validates :routine_title, presence: true

  # 指定した週のデータのみを取得
  scope :weekly, ->(now) { where(created_at: now.all_week) }
end
