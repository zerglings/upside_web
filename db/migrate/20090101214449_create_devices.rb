class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :unique_id, :limit => 64, :null => false
      t.datetime :last_activation, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end
    
    # find the device with some given device ID (at activation)
    add_index :devices, :unique_id, :unique => true, :null => false
  end

  def self.down
    remove_index :devices, :unique_id
    drop_table :devices
  end
end
