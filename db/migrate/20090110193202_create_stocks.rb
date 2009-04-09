class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.string :ticker, :limit => 16, :null => false
      t.integer :market_id, :limit => 4, :null => false
    end
    
    # Get the stock with a certain ticker.
    add_index :stocks, :ticker, :unique => true, :null => false
  end

  def self.down
    remove_index :stocks, :ticker
    drop_table :stocks
  end
end
