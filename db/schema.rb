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

ActiveRecord::Schema.define(version: 2018_10_19_002850) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bills", force: :cascade do |t|
    t.string "number"
    t.string "status"
    t.string "session"
    t.string "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "supports_gun_control"
    t.string "shorthand"
    t.string "location"
  end

  create_table "donations", force: :cascade do |t|
    t.string "value"
    t.string "lobbyist_id"
    t.string "representative_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "year"
  end

  create_table "lobbyists", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "representatives", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "party"
    t.string "beliefs"
    t.string "rating"
    t.string "img"
    t.string "district"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profession"
  end

  create_table "votes", force: :cascade do |t|
    t.string "position"
    t.string "bill_id"
    t.string "representative_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stance"
  end

end
