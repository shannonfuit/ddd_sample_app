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

ActiveRecord::Schema[7.1].define(version: 2024_03_07_094859) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contacts", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "uuid"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_contacts_on_email", unique: true
    t.index ["reset_password_token"], name: "index_contacts_on_reset_password_token", unique: true
  end

  create_table "customer_candidates", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_customer_candidates_on_uuid", unique: true
  end

  create_table "customer_jobs", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "status", null: false
    t.integer "spots"
    t.datetime "shift_starts_on"
    t.datetime "shift_ends_on"
    t.decimal "jobs", precision: 8, scale: 2
    t.decimal "wage_per_hour", precision: 8, scale: 2
    t.jsonb "work_location"
    t.jsonb "vacancy"
    t.jsonb "applications", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shift_ends_on"], name: "index_customer_jobs_on_shift_ends_on"
    t.index ["shift_starts_on"], name: "index_customer_jobs_on_shift_starts_on"
    t.index ["uuid", "shift_starts_on", "status"], name: "index_customer_jobs_on_uuid_and_shift_starts_on_and_status"
    t.index ["uuid"], name: "index_customer_jobs_on_uuid", unique: true
  end

  create_table "event_store_events", force: :cascade do |t|
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.jsonb "metadata"
    t.jsonb "data", null: false
    t.datetime "created_at", null: false
    t.datetime "valid_at"
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_on_event_id", unique: true
    t.index ["event_type"], name: "index_event_store_events_on_event_type"
    t.index ["valid_at"], name: "index_event_store_events_on_valid_at"
  end

  create_table "event_store_events_in_streams", force: :cascade do |t|
    t.string "stream", null: false
    t.integer "position"
    t.uuid "event_id", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_in_streams_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_in_streams_on_event_id"
    t.index ["stream", "event_id"], name: "index_event_store_events_in_streams_on_stream_and_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_events_in_streams_on_stream_and_position", unique: true
  end

  create_table "iam_users", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "role"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_iam_users_on_uuid", unique: true
  end

  create_table "job_fulfillment_users", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_job_fulfillment_users_on_uuid", unique: true
  end

  create_table "my_active_record_aggregates", force: :cascade do |t|
    t.string "uuid", null: false
    t.integer "amount_of_items"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_my_active_record_aggregates_on_uuid", unique: true
  end

  add_foreign_key "event_store_events_in_streams", "event_store_events", column: "event_id", primary_key: "event_id"
end
