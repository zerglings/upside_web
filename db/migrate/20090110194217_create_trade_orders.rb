class CreateTradeOrders < ActiveRecord::Migration
  def self.up
    create_table :trade_orders do |t|
      t.integer :portfolio_id, :limit => 8, :null => false
      t.integer :stock_id, :limit => 4, :null => false
      t.boolean :is_buy, :default => true, :null => false
      t.boolean :is_long, :default => true, :null => false
      t.decimal :stop_price, :precision => 8, :scale => 2, :null => true
      t.decimal :limit_price, :precision => 8, :scale => 2, :null => true
      t.datetime :expiration_time, :null => true
      t.integer :quantity, :limit => 8, :null => false
      t.integer :unfilled_quantity, :limit => 8, :null => false

      t.timestamps
    end
    
    add_index :trade_orders, :portfolio_id, :unique => false, :null => false
  end

  def self.down
    remove_index :trade_orders, :portfolio_id
    drop_table :trade_orders
  end
end
