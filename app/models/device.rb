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
