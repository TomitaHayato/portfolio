class CreateRoutines < ActiveRecord::Migration[7.0]
  def change
    create_table :routines do |t|
      t.references :user, foreign_key: true
      t.string :title, null:false
      t.text :description
      t.time :start_time, default: "07:00:00"
      t.boolean :is_active, default:false
      t.boolean :is_posted, default:false
      t.integer :completed_count, default: 0
      t.integer :copied_count, default: 0

      t.timestamps
    end
  end
end
