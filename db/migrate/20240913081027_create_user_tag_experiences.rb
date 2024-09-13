class CreateUserTagExperiences < ActiveRecord::Migration[7.0]
  def change
    create_table :user_tag_experiences do |t|
      t.references :user, foreign_key: true
      t.references :tag, foreign_key: true
      t.integer :experience_point, null: false, default: 1
      
      t.timestamps
    end
  end
end
