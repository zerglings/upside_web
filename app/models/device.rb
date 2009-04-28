# == Schema Information
# Schema version: 20090428015642
#
# Table name: devices
#
#  id              :integer(4)      not null, primary key
#  unique_id       :string(64)      not null
#  hardware_model  :string(32)      not null
#  os_name         :string(32)      not null
#  os_version      :string(32)      not null
#  app_version     :string(16)      not null
#  last_activation :datetime        not null
#  user_id         :integer(4)      not null
#  created_at      :datetime
#  updated_at      :datetime
#  last_ip         :string(64)      default("unknown"), not null
#  last_app_fprint :string(64)      default(""), not null
#

class Device < ActiveRecord::Base
  belongs_to :user
  
  # iPhone / iPod Touch id
  validates_length_of :unique_id, :is => 40, :allow_nil => false
  validates_uniqueness_of :unique_id
  
  # device type (e.g. iPhone1,2 or iPod2,1)
  validates_length_of :hardware_model, :in => 1..32, :allow_nil => false
  
  # device OS (e.g. iPhone OS)
  validates_length_of :os_name, :in => 1..32, :allow_nil => false
  
  # device OS version (e.g. 2.2.1)
  validates_length_of :os_version, :in => 1..32, :allow_nil => false
  
  # application version (e.g. 1.0)
  validates_length_of :app_version, :in => 1..16, :allow_nil => false
  
  # last IP that the device was seen at
  validates_length_of :last_ip, :in => 1..64, :allow_nil => false
  
  # last application finger-print sent from the device
  validates_length_of :last_app_fprint, :in => 0..64, :allow_nil => false
  
  # last time the game was activated
  validates_presence_of :last_activation
  validates_datetime :last_activation    
  
  # user id pointing to the last user on this device
  validates_presence_of :user_id
end
