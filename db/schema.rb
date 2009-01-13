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

ActiveRecord::Schema.define(:version => 20090111010751) do

  create_table "devices", :force => true do |t|
    t.string   "unique_id",       :limit => 64, :null => false
    t.datetime "last_activation",               :null => false
    t.integer  "user_id",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["unique_id"], :name => "index_devices_on_unique_id", :unique => true

  create_table "portfolios", :force => true do |t|
    t.integer  "user_id",                                   :null => false
    t.decimal  "cash",       :precision => 20, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trade_orders", :force => true do |t|
    t.integer  "portfolio_id",    :limit => 64,                                                 :null => false
    t.integer  "stock_id",        :limit => 64,                                                 :null => false
    t.boolean  "is_buy",                                                      :default => true, :null => false
    t.boolean  "is_long",                                                     :default => true, :null => false
    t.decimal  "stop_price",                    :precision => 8, :scale => 2
    t.decimal  "limit_price",                   :precision => 8, :scale => 2
    t.datetime "expiration_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trades", :force => true do |t|
    t.datetime "time",                                                       :null => false
    t.integer  "quantity",       :limit => 22,                               :null => false
    t.integer  "trade_order_id", :limit => 16,                               :null => false
    t.integer  "counterpart_id", :limit => 16,                               :null => false
    t.decimal  "price",                        :precision => 8, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name",          :limit => 64,                   :null => false
    t.string   "password_hash", :limit => 64,                   :null => false
    t.string   "password_salt", :limit => 4,                    :null => false
    t.boolean  "pseudo_user",                 :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["name"], :name => "index_users_on_name", :unique => true

end
