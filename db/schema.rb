# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150416011552) do

  create_table "categories", force: true do |t|
    t.string   "title",        limit: 255,               null: false
    t.text     "content",      limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "posts_count",  limit: 4,     default: 0
    t.integer  "photos_count", limit: 4,     default: 0
    t.string   "ancestry",     limit: 255
  end

  add_index "categories", ["ancestry"], name: "index_categories_on_ancestry", using: :btree

  create_table "categories_posts", force: true do |t|
    t.integer "post_id",     limit: 4, null: false
    t.integer "category_id", limit: 4, null: false
  end

  add_index "categories_posts", ["category_id"], name: "fk_category", using: :btree
  add_index "categories_posts", ["post_id"], name: "fk_post", using: :btree

  create_table "flickr_tokens", force: true do |t|
    t.string   "oauth_token",        limit: 255, default: "",        null: false
    t.string   "oauth_token_secret", limit: 255, default: "",        null: false
    t.string   "auth_url",           limit: 255, default: "",        null: false
    t.string   "verify_code",        limit: 255
    t.string   "access_token",       limit: 255
    t.string   "access_secret",      limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "status",             limit: 9,   default: "pending"
  end

  create_table "photos", force: true do |t|
    t.string   "title",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",     limit: 255
    t.string   "image_content_type",  limit: 255
    t.integer  "image_file_size",     limit: 4
    t.datetime "image_updated_at"
    t.integer  "sort",                limit: 4,     default: 100
    t.text     "image_meta",          limit: 65535
    t.float    "geo_latitude",        limit: 24
    t.float    "geo_longitude",       limit: 24
    t.text     "content",             limit: 65535
    t.text     "exif",                limit: 65535
    t.integer  "rating",              limit: 1,     default: 0
    t.integer  "publish_on_facebook", limit: 1,     default: 0
    t.integer  "publish_on_twitter",  limit: 1,     default: 0
    t.integer  "publish_on_flickr",   limit: 1,     default: 0
    t.integer  "publish_on_500px",    limit: 1,     default: 0
  end

  create_table "photos_tags", force: true do |t|
    t.integer "photo_id", limit: 4, null: false
    t.integer "tag_id",   limit: 4, null: false
  end

  add_index "photos_tags", ["photo_id"], name: "fk_photo", using: :btree
  add_index "photos_tags", ["tag_id"], name: "fk_tag", using: :btree

  create_table "posts", force: true do |t|
    t.string   "title",         limit: 255,   default: "", null: false
    t.text     "content",       limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.datetime "date_from"
    t.datetime "date_to"
    t.integer  "main_photo",    limit: 4
    t.float    "geo_latitude",  limit: 24
    t.float    "geo_longitude", limit: 24
  end

  add_index "posts", ["main_photo"], name: "main_photo", using: :btree

  create_table "posts_photos", force: true do |t|
    t.integer "post_id",  limit: 4, null: false
    t.integer "photo_id", limit: 4, null: false
  end

  add_index "posts_photos", ["photo_id"], name: "fk_photo", using: :btree
  add_index "posts_photos", ["post_id"], name: "fk_post", using: :btree

  create_table "posts_tags", force: true do |t|
    t.integer "post_id", limit: 4, null: false
    t.integer "tag_id",  limit: 4, null: false
  end

  add_index "posts_tags", ["post_id"], name: "fk_post", using: :btree
  add_index "posts_tags", ["tag_id"], name: "fk_tag", using: :btree

  create_table "tags", force: true do |t|
    t.string   "title",      limit: 255
    t.integer  "count",      limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "for",        limit: 5,   default: "post"
  end

  create_table "users", force: true do |t|
    t.string   "email",         limit: 255
    t.string   "password_hash", limit: 255
    t.string   "password_salt", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_foreign_key "categories_posts", "categories", name: "categories_posts_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "categories_posts", "posts", name: "categories_posts_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "photos_tags", "photos", name: "photos_tags_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "photos_tags", "tags", name: "photos_tags_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "posts", "photos", column: "main_photo", name: "posts_ibfk_1", on_update: :cascade, on_delete: :nullify
  add_foreign_key "posts_photos", "photos", name: "posts_photos_ibfk_2", on_update: :cascade, on_delete: :cascade
  add_foreign_key "posts_photos", "posts", name: "posts_photos_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "posts_tags", "posts", name: "posts_tags_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "posts_tags", "tags", name: "posts_tags_ibfk_2", on_update: :cascade, on_delete: :cascade
end
