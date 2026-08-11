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

ActiveRecord::Schema[8.1].define(version: 2026_08_11_022343) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "interests", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_interests_on_name", unique: true
  end

  create_table "photos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.boolean "primary", default: false, null: false
    t.string "rejection_reason"
    t.datetime "reviewed_at"
    t.integer "reviewed_by"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "status", "position"], name: "index_photos_on_user_id_and_status_and_position"
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "profile_interests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "interest_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["interest_id"], name: "index_profile_interests_on_interest_id"
    t.index ["user_id", "interest_id"], name: "index_profile_interests_on_user_id_and_interest_id", unique: true
    t.index ["user_id"], name: "index_profile_interests_on_user_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "education_verifications", "users"
  add_foreign_key "identity_verifications", "users"
  add_foreign_key "photos", "users"
  add_foreign_key "profile_interests", "interests"
  add_foreign_key "profile_interests", "users"
end
