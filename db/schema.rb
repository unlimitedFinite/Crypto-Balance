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

ActiveRecord::Schema.define(version: 2019_06_05_095834) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allocations", force: :cascade do |t|
    t.integer "allocation_pct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "coin_id"
    t.bigint "portfolio_id"
    t.index ["coin_id"], name: "index_allocations_on_coin_id"
    t.index ["portfolio_id"], name: "index_allocations_on_portfolio_id"
  end

  create_table "coins", force: :cascade do |t|
    t.string "name"
    t.string "symbol"
    t.float "price_usdt"
    t.boolean "is_base_coin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price_btc"
    t.float "lot_size"
    t.string "color"
    t.string "image"
  end

  create_table "orders", force: :cascade do |t|
    t.string "status"
    t.float "price"
    t.float "quantity"
    t.float "commission"
    t.string "side"
    t.string "type"
    t.string "binance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "base_coin_id"
    t.bigint "target_coin_id"
    t.index ["base_coin_id"], name: "index_orders_on_base_coin_id"
    t.index ["target_coin_id"], name: "index_orders_on_target_coin_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.string "rebalance_freq"
    t.date "next_rebalance_dt"
    t.bigint "user_id"
    t.float "current_value_usdt"
    t.bigint "coin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "current_value_btc"
    t.index ["coin_id"], name: "index_portfolios_on_coin_id"
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "positions", force: :cascade do |t|
    t.bigint "coin_id"
    t.float "quantity"
    t.float "value_usdt"
    t.date "as_of_dt"
    t.date "as_of_dt_end"
    t.bigint "portfolio_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "value_btc"
    t.index ["coin_id"], name: "index_positions_on_coin_id"
    t.index ["portfolio_id"], name: "index_positions_on_portfolio_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "api_key"
    t.string "secret_key"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "allocations", "coins"
  add_foreign_key "allocations", "portfolios"
  add_foreign_key "orders", "coins", column: "base_coin_id"
  add_foreign_key "orders", "coins", column: "target_coin_id"
  add_foreign_key "portfolios", "coins"
  add_foreign_key "portfolios", "users"
  add_foreign_key "positions", "coins"
  add_foreign_key "positions", "portfolios"
end
