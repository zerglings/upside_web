class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :unique_id, :limit => 64, :null => false
      t.string :hardware_model, :limit => 32, :null => false
      t.string :os_name, :limit => 32, :null => false
      t.string :os_version, :limit => 32, :null => false
      t.string :app_version, :limit => 16, :null => false
      t.datetime :last_activation, :null => false
      t.integer :user_id, :limit => 8, :null => false

      t.timestamps
    end
    
    # find the device with some given device ID (at activation)
    add_index :devices, :unique_id, :unique => true, :null => false
    
    # find all the devices belonging to a certain user
    add_index :devices, :user_id, :unique => false, :null => false
  end

  def self.down
    remove_index :devices, :unique_id
    remove_index :devices, :user_id
    drop_table :devices
  end
end
