class CreateOrderCancellations < ActiveRecord::Migration
  def self.up
    create_table :order_cancellations do |t|
      t.integer :trade_order_id, :null => false
      
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :order_cancellations
  end
end
