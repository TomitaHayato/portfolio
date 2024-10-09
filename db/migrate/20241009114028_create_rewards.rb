class CreateRewards < ActiveRecord::Migration[7.0]
  def change
    create_table :rewards do |t|
      t.string :name,     null: false
      t.string :condition, null: false
      t.string :description

      t.timestamps
    end
  end
end
