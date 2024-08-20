class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false, limit: 50
      t.integer :estimated_time_in_second, null: false
      t.references :routine, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
