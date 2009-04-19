class CreatePortfolioStats < ActiveRecord::Migration
  def self.up
    create_table :portfolio_stats do |t|
      t.integer :frequency, :limit => 1, :null => false
      t.integer :portfolio_id, :limit => 8, :null => false
      t.decimal :net_worth, :precision => 20, :scale => 2, :null => false
      t.integer :rank, :limit => 8, :null => true
    end
    
    # Bring up a user's stats.
    add_index :portfolio_stats, [:portfolio_id, :frequency],
              :unique => true, :null => false
    # Bring up the portfolios around a certain rank.
    add_index :portfolio_stats, [:frequency, :rank], :unique => false
  end

  def self.down
    remove_index :portfolio_stats, [:portfolio_id, :frequency]
    remove_index :portfolio_stats, [:frequency, :rank]
    
    drop_table :portfolio_stats
  end
end
