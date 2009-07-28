# == Schema Information
# Schema version: 20090728042053
#
# Table name: devices
#
#  id               :integer         not null, primary key
#  unique_id        :string(64)      not null
#  hardware_model   :string(32)      not null
#  os_name          :string(32)      not null
#  os_version       :string(32)      not null
#  app_version      :string(16)      not null
#  last_activation  :datetime        not null
#  user_id          :integer(8)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  last_ip          :string(64)      default("unknown"), not null
#  last_app_fprint  :string(64)      default(""), not null
#  app_id           :string(64)      default("unknown"), not null
#  app_push_token   :string(256)
#  app_provisioning :string(4)       default("?"), not null
#

class Device < ActiveRecord::Base
  belongs_to :user

  # Application's bundle ID. (us.costan.StockPlay)
  validates_length_of :app_id, :in => 1..64, :allow_nil => false

  # Provisioning info (e.g. simulator / device / debug / release / distribution)
  validates_length_of :app_provisioning, :in => 1..4, :allow_nil => false

  # Token for sending Push Notifications to the application.
  validates_length_of :app_push_token, :in => 1..256, :allow_nil => true

  # Application version (e.g. 1.0)
  validates_length_of :app_version, :in => 1..16, :allow_nil => false
  
  # device type (e.g. iPhone1,2 or iPod2,1)
  validates_length_of :hardware_model, :in => 1..32, :allow_nil => false

  # last application finger-print sent from the device
  validates_length_of :last_app_fprint, :in => 0..64, :allow_nil => false
  
  # device OS (e.g. iPhone OS)
  validates_length_of :os_name, :in => 1..32, :allow_nil => false
  
  # device OS version (e.g. 2.2.1)
  validates_length_of :os_version, :in => 1..32, :allow_nil => false
    
  # iPhone / iPod Touch id
  validates_length_of :unique_id, :is => 40, :allow_nil => false
  validates_uniqueness_of :unique_id
  
  # last time the game was activated
  validates_presence_of :last_activation
  validates_datetime :last_activation    
  
  # last IP that the device was seen at
  validates_length_of :last_ip, :in => 1..64, :allow_nil => false

  # user id pointing to the last user on this device
  validates_presence_of :user_id
end
