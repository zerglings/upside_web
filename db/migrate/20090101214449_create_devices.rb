class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :unique_id, :limit => 40, :null => false
      t.datetime :last_activation, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
