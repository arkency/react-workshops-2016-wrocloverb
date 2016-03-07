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

ActiveRecord::Schema.define(version: 20160306194436) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "conference_days", id: :uuid, default: "gen_random_uuid()", force: :cascade do |t|
    t.string   "label",         null: false
    t.datetime "from",          null: false
    t.datetime "to",            null: false
    t.uuid     "conference_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "conferences", id: :uuid, default: "gen_random_uuid()", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", id: :uuid, default: "gen_random_uuid()", force: :cascade do |t|
    t.string   "name",                         null: false
    t.string   "host",                         null: false
    t.text     "description",     default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "conference_id",                null: false
    t.integer  "time_in_minutes",              null: false
  end

  create_table "planned_events", id: :uuid, default: "gen_random_uuid()", force: :cascade do |t|
    t.uuid     "conference_day_id", null: false
    t.uuid     "event_id",          null: false
    t.datetime "start",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "planned_events", ["conference_day_id", "event_id"], name: "index_planned_events_on_conference_day_id_and_event_id", unique: true, using: :btree

end
