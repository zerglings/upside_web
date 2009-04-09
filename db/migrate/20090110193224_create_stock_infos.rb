class CreateStockInfos < ActiveRecord::Migration
  def self.up
    create_table :stock_infos do |t|
      t.integer :stock_id, :limit => 4, :null => false
      t.string :company_name, :limit => 128, :null => false

      t.timestamps
    end
    
    # Get extended information for a certain stock.
    add_index :stock_infos, :stock_id, :unique => true, :null => false
  end

  def self.down
    remove_index :stock_infos, :stock_id
    drop_table :stock_infos
  end
end
