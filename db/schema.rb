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

ActiveRecord::Schema.define(version: 20150228025114) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "commits", force: true do |t|
    t.decimal  "user_id",     precision: 21, scale: 0, null: false
    t.integer  "snippet_id",                           null: false
    t.text     "commit_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "docs", id: false, force: true do |t|
    t.string   "doc_id",     null: false
    t.string   "docname"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "docs", ["doc_id"], name: "index_docs_on_doc_id", unique: true, using: :btree

  create_table "notifs", force: true do |t|
    t.decimal  "from_id",    precision: 21, scale: 0,                 null: false
    t.decimal  "to_id",      precision: 21, scale: 0,                 null: false
    t.string   "doc_id",                                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "responded",                           default: false
  end

  create_table "requests", id: false, force: true do |t|
    t.decimal  "user_id",               precision: 21, scale: 0, null: false
    t.string   "username",   limit: 30
    t.string   "email",      limit: 30
    t.boolean  "granted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "requests", ["user_id"], name: "index_requests_on_user_id", unique: true, using: :btree

  create_table "snippets", force: true do |t|
    t.string "doc_id",   null: false
    t.string "title"
    t.string "video_id"
  end

  create_table "tasks", id: false, force: true do |t|
    t.string   "doc_id",                                              null: false
    t.decimal  "user_id",    precision: 21, scale: 0,                 null: false
    t.decimal  "admin_id",   precision: 21, scale: 0,                 null: false
    t.boolean  "done",                                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",                            default: false
    t.text     "note"
  end

  add_index "tasks", ["doc_id"], name: "index_tasks_on_doc_id", unique: true, using: :btree

  create_table "users", id: false, force: true do |t|
    t.decimal "user_id",             precision: 21, scale: 0,                 null: false
    t.string  "username", limit: 30
    t.string  "email",    limit: 30
    t.boolean "admin",                                        default: false
  end

  add_index "users", ["user_id"], name: "index_users_on_user_id", unique: true, using: :btree

  create_table "videos", id: false, force: true do |t|
    t.string "video_id", null: false
    t.string "title"
  end

  add_index "videos", ["video_id"], name: "index_videos_on_video_id", unique: true, using: :btree

end
