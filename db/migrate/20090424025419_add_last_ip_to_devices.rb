class AddLastIpToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :last_ip, :string, :limit => 64, :null => false,
               :default => "unknown"
  end

  def self.down
    remove_column :devices, :last_ip
  end
end
