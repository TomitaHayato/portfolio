class TaskTag < ApplicationRecord
  belongs_to :tag
  belongs_to :task

  validates :task_id, uniqueness: { scope: tag_id }
end
