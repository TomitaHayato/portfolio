class AddImageToRewards < ActiveRecord::Migration[7.0]
  def change
    add_column :rewards, :image, :string
  end
end
