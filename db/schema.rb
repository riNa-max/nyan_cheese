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

ActiveRecord::Schema.define(version: 2026_02_16_110030) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "album_follows", force: :cascade do |t|
    t.integer "owner_id", null: false
    t.integer "viewer_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_id", "viewer_id"], name: "index_album_follows_on_owner_id_and_viewer_id", unique: true
    t.index ["owner_id"], name: "index_album_follows_on_owner_id"
    t.index ["viewer_id"], name: "index_album_follows_on_viewer_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.integer "user_id", null: false
    t.integer "photo_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["photo_id"], name: "index_comments_on_photo_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "photo_tags", force: :cascade do |t|
    t.integer "photo_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["photo_id", "tag_id"], name: "index_photo_tags_on_photo_id_and_tag_id", unique: true
    t.index ["photo_id"], name: "index_photo_tags_on_photo_id"
    t.index ["tag_id"], name: "index_photo_tags_on_tag_id"
  end

  create_table "photos", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "share_links", force: :cascade do |t|
    t.integer "owner_id", null: false
    t.string "token", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_id"], name: "index_share_links_on_owner_id"
    t.index ["token"], name: "index_share_links_on_token", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name_ja"
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["name_ja"], name: "index_tags_on_name_ja"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "line_user_id"
    t.string "provider"
    t.string "uid"
    t.string "line_link_token"
    t.datetime "line_link_token_generated_at"
    t.datetime "last_photo_at"
    t.datetime "last_reminded_at"
    t.boolean "remind_enabled", default: true, null: false
    t.integer "remind_after_days", default: 3, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["line_link_token"], name: "index_users_on_line_link_token", unique: true
    t.index ["line_user_id"], name: "index_users_on_line_user_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "album_follows", "users", column: "owner_id"
  add_foreign_key "album_follows", "users", column: "viewer_id"
  add_foreign_key "comments", "photos"
  add_foreign_key "comments", "users"
  add_foreign_key "photo_tags", "photos"
  add_foreign_key "photo_tags", "tags"
  add_foreign_key "photos", "users"
  add_foreign_key "share_links", "users", column: "owner_id"
end
