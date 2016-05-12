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

ActiveRecord::Schema.define(version: 20160508154344) do

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
    t.integer  "artist_num"
    t.text     "artist_photo"
    t.string   "artist_name"
    t.integer  "album_num"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
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
    t.integer  "keyNum"
    t.float    "percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "singers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "songs", force: :cascade do |t|
    t.integer  "album_id"
    t.string   "title"
    t.string   "ganre1"
    t.string   "ganre2"
    t.string   "runtime"
    t.text     "lyrics"
    t.string   "songwriter"
    t.string   "composer"
    t.integer  "singer_id"
    t.integer  "artist_num"
    t.integer  "team_id"
    t.integer  "album_num"
    t.text     "artist_photo"
    t.text     "jacket"
    t.integer  "song_tjnum"
    t.integer  "song_num"
    t.string   "lowkey"
    t.string   "highkey"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "t_a_s", force: :cascade do |t|
    t.integer  "singer_id"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
