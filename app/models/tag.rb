class Tag < ApplicationRecord
  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags

  # タグがタスクに設定されているかどうか
  def is_on_task?(task)
    return self.tasks.include?(task)
  end
end
