class CreateStockCacheLines < ActiveRecord::Migration
  def self.up
    create_table :stock_cache_lines do |t|
      t.string :ticker, :limit => 16, :null => false
      t.string :info_type, :limit => 8, :null => false
      t.string :value, :limit => 1024, :null => false
      t.datetime :updated_at
    end
    add_index :stock_cache_lines, [:ticker, :info_type], :unique => true,
                                                         :null => false
  end

  def self.down
    remove_index :stock_cache_lines, [:ticker, :info_type]
    drop_table :stock_cache_lines
  end
end
