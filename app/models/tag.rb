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

  # { タグ名: 0, ... }
  def self.make_empty_exp_hash
    empty_exp_hash = {}

    find_each { |tag| empty_exp_hash[tag.name] = 0 }

    empty_exp_hash
  end
end
