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

ActiveRecord::Schema[8.1].define(version: 2026_08_11_020111) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_admin_users_on_email_address", unique: true
  end

  create_table "education_verifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "degree"
    t.integer "education_level", default: 0, null: false
    t.string "provider", default: "mock", null: false
    t.string "rejection_reason"
    t.string "report_no", null: false
    t.jsonb "response"
    t.datetime "reviewed_at"
    t.integer "reviewed_by"
    t.string "school"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "verified_at"
    t.string "verify_code", null: false
    t.index ["user_id", "status"], name: "index_education_verifications_on_user_id_and_status"
    t.index ["user_id"], name: "index_education_verifications_on_user_id"
  end

  create_table "identity_verifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "full_name", null: false
    t.string "id_number", null: false
    t.string "provider", default: "mock", null: false
    t.string "rejection_reason"
    t.jsonb "response"
    t.datetime "reviewed_at"
    t.integer "reviewed_by"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "verified_at"
    t.index ["user_id", "status"], name: "index_identity_verifications_on_user_id_and_status"
    t.index ["user_id"], name: "index_identity_verifications_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.bigint "sessionable_id", null: false
    t.string "sessionable_type", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["sessionable_type", "sessionable_id"], name: "index_sessions_on_sessionable"
  end

  create_table "sms_codes", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.string "code_digest", null: false
    t.datetime "consumed_at"
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "phone", null: false
    t.integer "purpose", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["phone", "purpose", "expires_at"], name: "index_sms_codes_on_phone_and_purpose_and_expires_at"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "avatar_photo_id"
    t.text "bio"
    t.date "birthdate"
    t.string "city"
    t.datetime "created_at", null: false
    t.integer "education_level", default: 0, null: false
    t.integer "gender", default: 0, null: false
    t.integer "height_cm"
    t.string "job"
    t.datetime "last_active_at"
    t.string "nickname"
    t.string "password_digest"
    t.string "phone", null: false
    t.integer "pref_age_max", default: 45, null: false
    t.integer "pref_age_min", default: 18, null: false
    t.integer "pref_distance_km", default: 50, null: false
    t.integer "pref_gender", default: 2, null: false
    t.boolean "pref_show_distance", default: true, null: false
    t.integer "status", default: 1, null: false
    t.datetime "updated_at", null: false
    t.integer "verification_level", default: 0, null: false
    t.datetime "verified_at"
    t.index ["gender", "verification_level", "status"], name: "index_users_on_gender_and_verification_level_and_status"
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  add_foreign_key "education_verifications", "users"
  add_foreign_key "identity_verifications", "users"
end
