class AddNotificationToRoutines < ActiveRecord::Migration[7.0]
  def change
    add_column :routines, :notification, :integer, default: 0
  end
end
