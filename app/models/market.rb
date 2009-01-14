class Market < ActiveRecord::Base
  has_many :stocks, :dependent => :nullify
  
  validates_length_of :name, :in => 3..50, :allow_nil => false
  
end
