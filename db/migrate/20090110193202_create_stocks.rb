class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.string :ticker, :null => false
      t.integer :market_id, :null => false
      t.timestamps
    end
    
    add_index :stocks, :ticker, :unique => true
  end

  def self.down
    drop_index :stocks, :ticker
    drop_table :stocks
  end
end
