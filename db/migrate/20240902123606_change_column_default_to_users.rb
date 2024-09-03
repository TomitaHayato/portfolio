class ChangeColumnDefaultToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :role, from: nil, to: 1
    change_column_default :users, :complete_routines_count, from: nil, to: 0
  end
end
