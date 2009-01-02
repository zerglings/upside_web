class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :password_hash
      t.string :password_salt

      t.timestamps
    end
    
    # find the device with some given device ID (at activation)
    add_index :users, :name, :unique => true   
  end

  def self.down
    remove_index :users, :name
    drop_table :users
  end
end
