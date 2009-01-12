class Market < ActiveRecord::Base
  has_many :stocks
  
  validates_length_of :name, :minimum => 3, :allow_nil => false
  validates_length_of :name, :maximum => 50, :allow_nil => false
  
end
