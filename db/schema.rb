# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_09_02_123606) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "routines", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title", null: false
    t.text "description"
    t.time "start_time", default: "2000-01-01 07:00:00"
    t.boolean "is_active", default: false
    t.boolean "is_posted", default: false
    t.integer "completed_count", default: 0
    t.integer "copied_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "posted_at"
    t.index ["user_id"], name: "index_routines_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", limit: 50, null: false
    t.integer "estimated_time_in_second", default: 60, null: false
    t.bigint "routine_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["routine_id"], name: "index_tasks_on_routine_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.integer "role", default: 1, null: false
    t.integer "complete_routines_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "routines", "users"
  add_foreign_key "tasks", "routines"
end
