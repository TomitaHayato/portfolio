class CreateQuickRoutineTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :quick_routine_templates do |t|
      t.references :user       , null: false, foreign_key: true
      t.string     :title      , null: false, default: "new ルーティン"
      t.string     :description
      t.time       :start_time , default: "07:00:00"

      t.timestamps
    end
  end
end
