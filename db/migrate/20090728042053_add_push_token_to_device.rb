class AddPushTokenToDevice < ActiveRecord::Migration
  def self.up
    add_column :devices, :app_id, :string, :limit => 64, :null => false,
               :default => 'unknown'
    add_column :devices, :app_push_token, :string, :limit => 256, :null => true
    add_column :devices, :app_provisioning, :string, :limit => 4,
               :null => false, :default => '?'
  end

  def self.down
    remove_column :devices, :app_id
    remove_column :devices, :app_provisioning
    remove_column :devices, :app_push_id
  end
end
