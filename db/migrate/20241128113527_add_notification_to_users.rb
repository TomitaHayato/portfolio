class AddNotificationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :notification, :integer, default: 0
  end
end
