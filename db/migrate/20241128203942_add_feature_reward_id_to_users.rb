class AddFeatureRewardIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :feature_reward, foreign_key: { to_table: :rewards }
  end
end
