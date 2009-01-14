class CreateStockInfos < ActiveRecord::Migration
  def self.up
    create_table :stock_infos do |t|
      t.integer :stock_id, :null => false
      t.string :company_name, :limit => 128, :null => false

      t.timestamps
    end
    
    add_index :stock_infos, :stock_id, :unique => true
  end

  def self.down
    drop_table :stock_infos
  end
end
