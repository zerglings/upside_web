class CreateImobilePushNotifications < ActiveRecord::Migration
  def self.up
    create_table :imobile_push_notifications do |t|
      t.integer :device_id, :limit => 8, :null => false
      t.string :payload, :limit => 4.kilobytes, :null => true
      t.integer :subject_id, :limit => 8, :null => false
      t.string :subject_type, :limit => 64, :null => false

      t.datetime :created_at
    end
  end

  def self.down
    drop_table :imobile_push_notifications
  end
end
