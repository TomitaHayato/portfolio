class AddLevelToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :level, :integer, default: 1, null: false
  end
end
