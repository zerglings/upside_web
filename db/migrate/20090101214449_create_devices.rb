class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :unique_id
      t.datetime :last_activation
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
