class CreatePortfolios < ActiveRecord::Migration
  def self.up
    create_table :portfolios do |t|
      t.integer :user_id, :limit => 64, :null => false
      t.decimal :cash, :precision => 20, :scale => 2, :null => false,
                       :default => Portfolio::NEW_PLAYER_CASH

      t.timestamps
    end
    
    # Get a user's portfolio.
    add_index :portfolios, :user_id, :unique => true, :null => false
  end

  def self.down
    remove_index :portfolios, :user_id    
    drop_table :portfolios
  end
end
