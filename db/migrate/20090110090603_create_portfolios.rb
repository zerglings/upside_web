class CreatePortfolios < ActiveRecord::Migration
  def self.up
    create_table :portfolios do |t|
      t.integer :user_id, :null => false
      t.decimal :cash, :precision => 20, :scale => 2, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :portfolios
  end
end
