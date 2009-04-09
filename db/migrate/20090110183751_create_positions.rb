class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.integer :portfolio_id, :limit => 8, :null => false
      t.integer :stock_id, :limit => 4, :null => false
      t.boolean :is_long, :null => false
      t.integer :quantity, :limit => 8, :null => false
      t.float :average_base_cost, :decimal, :precision => 8, :scale => 2

      t.timestamps
    end
    
    # Get all the positions in a portfolio.
    # Get the positions for a cetain stock in the portfolio.
    add_index :positions, [:portfolio_id, :stock_id, :is_long], :unique => true
  end

  def self.down
    remove_index :positions, [:portfolio_id, :stock_id, :is_long]
    drop_table :positions
  end
end
