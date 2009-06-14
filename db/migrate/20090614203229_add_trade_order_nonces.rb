class AddTradeOrderNonces < ActiveRecord::Migration
  def self.up
    add_column :trade_orders, :client_nonce, :string, :limit => 32,
               :null => true
    add_index :trade_orders, [:portfolio_id, :client_nonce],
              :null => true, :unique => false
  end

  def self.down
    remove_index :trade_orders, [:portfolio_id, :client_nonce]
    remove_column :trade_orders, :client_nonce
  end
end
