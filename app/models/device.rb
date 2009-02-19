# == Schema Information
# Schema version: 20090120032718
#
# Table name: devices
#
#  id              :integer         not null, primary key
#  unique_id       :string(64)      not null
#  last_activation :datetime        not null
#  user_id         :integer         not null
#  created_at      :datetime
#  updated_at      :datetime
#

class Device < ActiveRecord::Base
  belongs_to :user
  
  # iPhone id
  validates_length_of :unique_id,
                      :is => 40,
                      :allow_nil => false
  validates_uniqueness_of :unique_id
  
  # last time game used
  validates_presence_of :last_activation
  validates_datetime :last_activation    
  
  # user id to link to user
  validates_presence_of :user_id
end
