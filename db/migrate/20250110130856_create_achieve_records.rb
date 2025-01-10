class CreateAchieveRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :achieve_records do |t|
      t.string     :routine_title, null: false
      t.references :user         , null: false, foreign_key: true
      t.references :routine                   , foreign_key: true

      t.timestamps
    end
  end
end
