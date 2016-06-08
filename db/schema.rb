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

ActiveRecord::Schema.define(version: 20160603162717) do

  create_table "administers", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "albums", force: :cascade do |t|
    t.string   "title"
    t.string   "ganre1"
    t.string   "ganre2"
    t.string   "publisher"
    t.string   "agency"
    t.string   "released_date"
    t.text     "jacket"
    t.integer  "team_id"
    t.integer  "singer_id"
    t.integer  "album_num"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "albums_singers", force: :cascade do |t|
    t.integer  "singer_id"
    t.integer  "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "albums_teams", force: :cascade do |t|
    t.integer  "album_id"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_tj_popular_ranks", force: :cascade do |t|
    t.string   "symd"
    t.string   "eymd"
    t.integer  "song_rank"
    t.integer  "song_num"
    t.string   "song_title"
    t.string   "song_singer"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "interval_keys", force: :cascade do |t|
    t.string   "key"
    t.integer  "number"
    t.float    "percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mylist_songs", force: :cascade do |t|
    t.integer  "mylist_id"
    t.integer  "song_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mylists", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "singers", force: :cascade do |t|
    t.string   "name"
    t.string   "photo"
    t.integer  "artist_num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "singers_teams", force: :cascade do |t|
    t.integer  "singer_id"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "songs", force: :cascade do |t|
    t.integer  "album_id"
    t.integer  "singer_id"
    t.integer  "team_id"
    t.string   "title"
    t.string   "ganre1"
    t.string   "ganre2"
    t.string   "runtime"
    t.text     "lyrics"
    t.string   "writer"
    t.string   "composer"
    t.string   "youtube"
    t.text     "jacket"
    t.integer  "song_tjnum"
    t.integer  "song_num"
    t.string   "lowkey"
    t.string   "highkey"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_teams", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "team2_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "photo"
    t.integer  "artist_num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   default: "", null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
