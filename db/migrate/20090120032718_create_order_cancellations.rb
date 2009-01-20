class CreateOrderCancellations < ActiveRecord::Migration
  def self.up
    create_table :order_cancellations do |t|
      t.integer :trade_order_id, :null => false
      
      t.datetime :created_at
    end
    add_index :order_cancellations, :trade_order_id, :unique => true,
              :null => false
  end

  def self.down
    remove_index :order_cancellations, :trade_order_id
    drop_table :order_cancellations
  end
end
