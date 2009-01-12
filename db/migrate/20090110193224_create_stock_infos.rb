class CreateStockInfos < ActiveRecord::Migration
  def self.up
    create_table :stock_infos do |t|
      t.integer :stock_id, :null => false
      t.string :company_name

      t.timestamps
    end
  end

  def self.down
    drop_table :stock_infos
  end
end
