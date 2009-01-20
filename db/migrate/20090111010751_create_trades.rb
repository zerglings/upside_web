class CreateTrades < ActiveRecord::Migration
  def self.up
    create_table :trades do |t|
      t.datetime :time, :null => false
      t.integer :quantity, :null => false, :limit => 22
      t.integer :trade_order_id, :null => false, :limit => 16
      t.integer :counterpart_id, :null => true, :limit => 16
      t.decimal :price, :null => false, :precision => 8, :scale => 2

      t.datetime :created_at
    end
    
    # Get the trades associated with a certain order.
    add_index :trades, :trade_order_id, :unique => false
  end

  def self.down
    remove_index :trades, :trade_order_id
    drop_table :trades
  end
end
