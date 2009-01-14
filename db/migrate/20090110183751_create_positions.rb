class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.integer :portfolio_id, :null => false
      t.integer :stock_id, :null => false
      t.boolean :is_long, :null => false
      t.integer :quantity, :null => false
      t.float :average_base_cost, :decimal, :precision => 8, :scale => 2, :limit => 1048576

      t.timestamps
    end
    
    add_index :positions, [:portfolio_id, :stock_id, :is_long], :unique => true
  end

  def self.down
    remove_index :positions, [:portfolio_id, :stock_id, :is_long]
    drop_table :positions
  end
end
