class CreateLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.references :user, foreign_key: true
      t.references :routine, foreign_key: true
      t.timestamps
    end
    add_index :likes, [:user_id, :routine_id], unique: true
  end
end
