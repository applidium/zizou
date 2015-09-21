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

ActiveRecord::Schema.define(version: 20150911122125) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "challenges", force: :cascade do |t|
    t.string   "player1_id"
    t.string   "player2_id"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "elos", force: :cascade do |t|
    t.integer  "player_id"
    t.float    "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "elos", ["player_id"], name: "index_elos_on_player_id", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer  "team_player1_id"
    t.integer  "team_player2_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "games", ["team_player1_id"], name: "index_games_on_team_player1_id", using: :btree
  add_index "games", ["team_player2_id"], name: "index_games_on_team_player2_id", using: :btree

  create_table "players", force: :cascade do |t|
    t.string   "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "type"
  end

  create_table "team_players", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "player_id"
    t.integer  "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "team_players", ["player_id"], name: "index_team_players_on_player_id", using: :btree
  add_index "team_players", ["team_id"], name: "index_team_players_on_team_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "attack"
    t.integer  "midfield"
    t.integer  "defense"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "total"
  end

  add_foreign_key "elos", "players"
  add_foreign_key "team_players", "players"
  add_foreign_key "team_players", "teams"
end
