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

ActiveRecord::Schema[7.0].define(version: 2025_01_10_130856) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achieve_records", force: :cascade do |t|
    t.string "routine_title", null: false
    t.bigint "user_id", null: false
    t.bigint "routine_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["routine_id"], name: "index_achieve_records_on_routine_id"
    t.index ["user_id"], name: "index_achieve_records_on_user_id"
  end

  create_table "authentications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_authentications_on_provider_and_uid"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.integer "subject", default: 0, null: false
    t.integer "is_need_response", default: 0, null: false
    t.text "message", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "routine_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["routine_id"], name: "index_likes_on_routine_id"
    t.index ["user_id", "routine_id"], name: "index_likes_on_user_id_and_routine_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "quick_routine_templates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", default: "new ルーティン", null: false
    t.string "description"
    t.time "start_time", default: "2000-01-01 07:00:00"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_quick_routine_templates_on_user_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.string "name", null: false
    t.string "condition", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
  end

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

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_tags", force: :cascade do |t|
    t.bigint "task_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_task_tags_on_tag_id"
    t.index ["task_id", "tag_id"], name: "index_task_tags_on_task_id_and_tag_id", unique: true
    t.index ["task_id"], name: "index_task_tags_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", limit: 25, null: false
    t.integer "estimated_time_in_second", default: 60, null: false
    t.bigint "routine_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["routine_id"], name: "index_tasks_on_routine_id"
  end

  create_table "user_rewards", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "reward_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reward_id"], name: "index_user_rewards_on_reward_id"
    t.index ["user_id", "reward_id"], name: "index_user_rewards_on_user_id_and_reward_id", unique: true
    t.index ["user_id"], name: "index_user_rewards_on_user_id"
  end

  create_table "user_tag_experiences", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "tag_id"
    t.integer "experience_point", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_user_tag_experiences_on_tag_id"
    t.index ["user_id"], name: "index_user_tag_experiences_on_user_id"
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
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer "access_count_to_reset_password_page", default: 0
    t.string "avatar"
    t.integer "level", default: 1, null: false
    t.integer "notification", default: 0
    t.bigint "feature_reward_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["feature_reward_id"], name: "index_users_on_feature_reward_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "achieve_records", "routines"
  add_foreign_key "achieve_records", "users"
  add_foreign_key "likes", "routines"
  add_foreign_key "likes", "users"
  add_foreign_key "quick_routine_templates", "users"
  add_foreign_key "routines", "users"
  add_foreign_key "task_tags", "tags"
  add_foreign_key "task_tags", "tasks"
  add_foreign_key "tasks", "routines"
  add_foreign_key "user_rewards", "rewards"
  add_foreign_key "user_rewards", "users"
  add_foreign_key "user_tag_experiences", "tags"
  add_foreign_key "user_tag_experiences", "users"
  add_foreign_key "users", "rewards", column: "feature_reward_id"
end
