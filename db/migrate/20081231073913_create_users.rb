class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name, :limit => 64, :null => false
      t.string :password_hash, :limit => 64, :null => false
      t.string :password_salt, :limit => 4, :null => false
      t.boolean :pseudo_user, :default => true, :null => false
        
      t.timestamps
    end
    
    # speed up User.authenticate (login)
    add_index :users, :name, :unique => true, :null => false
  end

  def self.down
    remove_index :users, :name
    drop_table :users
  end
end
