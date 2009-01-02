class Device < ActiveRecord::Base
  belongs_to :user
  
  # iPhone id
  validates_uniqueness_of :unique_id
  validates_length_of :unique_id,
                      :is => 40,
                      :allow_nil => false
  
  # last time game used
  validates_presence_of :last_activation
  validates_date_time :last_activation    
  
  # user id to link to user
  validates_presence_of :user_id
end
