class CreateUserRewards < ActiveRecord::Migration[7.0]
  def change
    create_table :user_rewards do |t|
      t.references :user,   foreign_key: true
      t.references :reward, foreign_key: true

      t.timestamps
    end
    add_index :user_rewards, [:user_id, :reward_id], unique: true
  end
end
