class RemoveNotificationFromRoutines < ActiveRecord::Migration[7.0]
  def change
    remove_column :routines, :notification, :integer
  end
end
