class ChangeTitleLimitInTasks < ActiveRecord::Migration[7.0]
  def change
    change_column :tasks, :title, :string, limit: 25
  end
end
