class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.integer :portfolio_id, :null => false
      t.integer :stock_id, :null => false
      t.boolean :is_long?, :null => false
      t.integer :quantity, :default => 0, :null => false
      t.integer :average_base_cost, :limit => 1000000

      t.timestamps
    end
    
    add_index :positions, :portfolio_id, :unique => true
  end

  def self.down
    remove_index :positions, :portfolio_id
    drop_table :positions
  end
end
