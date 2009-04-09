class AddAdjustingTradeOrders < ActiveRecord::Migration
  def self.up
    add_column :trade_orders, :adjusting_order_id, :integer, :limit => 8,
               :null => true
  end

  def self.down
    remove_column :trade_orders, :adjusting_order_id
  end
end
