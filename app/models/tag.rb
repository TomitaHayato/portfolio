class Tag < ApplicationRecord
  has_many :task_tags           , dependent: :destroy
  has_many :tasks               , through:   :task_tags
  has_many :user_tag_experiences, dependent: :destroy
  has_many :users               , through:   :user_tag_experiences

  validates :name, presence: true

  # タグがタスクに設定されているかどうか
  def on_task?(task)
    tasks.include?(task)
  end
end
