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
    t.column "unique_id",       :string,   :limit => 64, :null => false
    t.column "last_activation", :datetime,               :null => false
    t.column "user_id",         :integer,                :null => false
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
  end

  add_index "devices", ["unique_id"], :name => "index_devices_on_unique_id", :unique => true
  add_index "devices", ["user_id"], :name => "index_devices_on_user_id"

  create_table "markets", :force => true do |t|
    t.column "name",       :string,   :limit => 64, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "order_cancellations", :force => true do |t|
    t.column "trade_order_id", :integer,  :null => false
    t.column "created_at",     :datetime
  end

  add_index "order_cancellations", ["trade_order_id"], :name => "index_order_cancellations_on_trade_order_id", :unique => true

  create_table "portfolios", :force => true do |t|
    t.column "user_id",    :integer,                                                       :null => false
    t.column "cash",       :decimal,  :precision => 20, :scale => 2, :default => 250000.0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "portfolios", ["user_id"], :name => "index_portfolios_on_user_id", :unique => true

  create_table "positions", :force => true do |t|
    t.column "portfolio_id",      :integer,  :null => false
    t.column "stock_id",          :integer,  :null => false
    t.column "is_long",           :boolean,  :null => false
    t.column "quantity",          :integer,  :null => false
    t.column "average_base_cost", :float
    t.column "decimal",           :float
    t.column "created_at",        :datetime
    t.column "updated_at",        :datetime
  end

  add_index "positions", ["portfolio_id", "stock_id", "is_long"], :name => "index_positions_on_portfolio_id_and_stock_id_and_is_long", :unique => true

  create_table "stock_infos", :force => true do |t|
    t.column "stock_id",     :integer,                 :null => false
    t.column "company_name", :string,   :limit => 128, :null => false
    t.column "created_at",   :datetime
    t.column "updated_at",   :datetime
  end

  add_index "stock_infos", ["stock_id"], :name => "index_stock_infos_on_stock_id", :unique => true

  create_table "stocks", :force => true do |t|
    t.column "ticker",    :string,  :limit => 16, :null => false
    t.column "market_id", :integer,               :null => false
  end

  add_index "stocks", ["ticker"], :name => "index_stocks_on_ticker", :unique => true

  create_table "trade_orders", :force => true do |t|
    t.column "portfolio_id",      :integer,                                                  :null => false
    t.column "stock_id",          :integer,                                                  :null => false
    t.column "is_buy",            :boolean,                                :default => true, :null => false
    t.column "is_long",           :boolean,                                :default => true, :null => false
    t.column "stop_price",        :decimal,  :precision => 8, :scale => 2
    t.column "limit_price",       :decimal,  :precision => 8, :scale => 2
    t.column "expiration_time",   :datetime
    t.column "quantity",          :integer,                                                  :null => false
    t.column "unfilled_quantity", :integer,                                                  :null => false
    t.column "created_at",        :datetime
    t.column "updated_at",        :datetime
  end

  add_index "trade_orders", ["portfolio_id"], :name => "index_trade_orders_on_portfolio_id"

  create_table "trades", :force => true do |t|
    t.column "time",           :datetime,                               :null => false
    t.column "quantity",       :integer,                                :null => false
    t.column "trade_order_id", :integer,                                :null => false
    t.column "counterpart_id", :integer
    t.column "price",          :decimal,  :precision => 8, :scale => 2, :null => false
    t.column "created_at",     :datetime
  end

  add_index "trades", ["trade_order_id"], :name => "index_trades_on_trade_order_id"

  create_table "users", :force => true do |t|
    t.column "name",          :string,   :limit => 64,                    :null => false
    t.column "password_hash", :string,   :limit => 64,                    :null => false
    t.column "password_salt", :string,   :limit => 4,                     :null => false
    t.column "pseudo_user",   :boolean,                :default => true,  :null => false
    t.column "is_admin",      :boolean,                :default => false, :null => false
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
  end

  add_index "users", ["name"], :name => "index_users_on_name", :unique => true

end
