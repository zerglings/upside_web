# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090120032718) do

  create_table "devices", :force => true do |t|
    t.string   "unique_id",       :limit => 64, :null => false
    t.datetime "last_activation",               :null => false
    t.integer  "user_id",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["unique_id"], :name => "index_devices_on_unique_id", :unique => true
  add_index "devices", ["user_id"], :name => "index_devices_on_user_id"

  create_table "markets", :force => true do |t|
    t.string   "name",       :limit => 64, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_cancellations", :force => true do |t|
    t.integer  "trade_order_id", :null => false
    t.datetime "created_at"
  end

  add_index "order_cancellations", ["trade_order_id"], :name => "index_order_cancellations_on_trade_order_id", :unique => true

  create_table "portfolios", :force => true do |t|
    t.integer  "user_id",                                                         :null => false
    t.decimal  "cash",       :precision => 20, :scale => 2, :default => 250000.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portfolios", ["user_id"], :name => "index_portfolios_on_user_id", :unique => true

  create_table "positions", :force => true do |t|
    t.integer  "portfolio_id",      :null => false
    t.integer  "stock_id",          :null => false
    t.boolean  "is_long",           :null => false
    t.integer  "quantity",          :null => false
    t.float    "average_base_cost"
    t.float    "decimal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "positions", ["portfolio_id", "stock_id", "is_long"], :name => "index_positions_on_portfolio_id_and_stock_id_and_is_long", :unique => true

  create_table "stock_infos", :force => true do |t|
    t.integer  "stock_id",                    :null => false
    t.string   "company_name", :limit => 128, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_infos", ["stock_id"], :name => "index_stock_infos_on_stock_id", :unique => true

  create_table "stocks", :force => true do |t|
    t.string  "ticker",    :limit => 16, :null => false
    t.integer "market_id",               :null => false
  end

  add_index "stocks", ["ticker"], :name => "index_stocks_on_ticker", :unique => true

  create_table "trade_orders", :force => true do |t|
    t.integer  "portfolio_id",                                                      :null => false
    t.integer  "stock_id",                                                          :null => false
    t.boolean  "is_buy",                                          :default => true, :null => false
    t.boolean  "is_long",                                         :default => true, :null => false
    t.decimal  "stop_price",        :precision => 8, :scale => 2
    t.decimal  "limit_price",       :precision => 8, :scale => 2
    t.datetime "expiration_time"
    t.integer  "quantity",                                                          :null => false
    t.integer  "unfilled_quantity",                                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trade_orders", ["portfolio_id"], :name => "index_trade_orders_on_portfolio_id"

  create_table "trades", :force => true do |t|
    t.datetime "time",                                         :null => false
    t.integer  "quantity",                                     :null => false
    t.integer  "trade_order_id",                               :null => false
    t.integer  "counterpart_id"
    t.decimal  "price",          :precision => 8, :scale => 2, :null => false
    t.datetime "created_at"
  end

  add_index "trades", ["trade_order_id"], :name => "index_trades_on_trade_order_id"

  create_table "users", :force => true do |t|
    t.string   "name",          :limit => 64,                    :null => false
    t.string   "password_hash", :limit => 64,                    :null => false
    t.string   "password_salt", :limit => 4,                     :null => false
    t.boolean  "pseudo_user",                 :default => true,  :null => false
    t.boolean  "is_admin",                    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["name"], :name => "index_users_on_name", :unique => true

end
