class CreateTradeOrders < ActiveRecord::Migration
  def self.up
    create_table :trade_orders do |t|
      t.integer :portfolio_id, :limit => 64, :null => false
      t.integer :stock_id, :limit => 64, :null => false
      t.boolean :is_buy, :default => true, :null => false
      t.boolean :is_long, :default => true, :null => false
      t.decimal :stop_price, :precision => 8, :scale => 2, :null => true
      t.decimal :limit_price, :precision => 8, :scale => 2, :null => true
      t.datetime :expiration_time, :null => true
      t.integer :quantity, :null => false, :limit => 22

      t.timestamps
    end
    
    add_index :trade_orders, :portfolio_id, :unique => false, :null => false
  end

  def self.down
    drop_table :trade_orders
  end
end
