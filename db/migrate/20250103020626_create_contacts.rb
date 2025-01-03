class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.string  :name            , null: false
      t.string  :email           , null: false
      t.integer :subject         , null: false, default: 0
      t.integer :is_need_response, null: false, default: 0
      t.text    :message         , null: false

      t.timestamps
    end
  end
end
