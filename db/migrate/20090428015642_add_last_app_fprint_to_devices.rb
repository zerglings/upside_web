class AddLastAppFprintToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :last_app_fprint, :string, :limit => 64,
                :null => false, :default => ""
  end

  def self.down
    remove_column :devices, :last_app_fprint
  end
end
