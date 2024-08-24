class AddColumnToRoutines < ActiveRecord::Migration[7.0]
  def change
    add_column :routines, :posted_at, :datetime 
  end
end
