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

ActiveRecord::Schema.define(version: 20161115001012) do

  create_table "api_keys", force: :cascade do |t|
    t.string   "service"
    t.string   "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "weather_forecasts", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.float    "precip"
    t.datetime "forecasted_on"
    t.datetime "date"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "weather_reports", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.float    "precip"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "date"
    t.integer  "weather_station_id"
    t.index ["date"], name: "index_weather_reports_on_date"
    t.index ["latitude"], name: "index_weather_reports_on_latitude"
    t.index ["longitude"], name: "index_weather_reports_on_longitude"
    t.index ["weather_station_id"], name: "index_weather_reports_on_weather_station_id"
  end

  create_table "weather_station_alerts", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "alert_for"
    t.float    "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float    "old_sum"
    t.float    "recent_sum"
  end

  create_table "weather_stations", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.index ["user_id"], name: "index_weather_stations_on_user_id"
  end

end
