class StockInfo < ActiveRecord::Base
  has_one :stock
  
#  set_primary_key :stock_id
  
  validates_numericality_of :stock_id, :greater_than => 0, :allow_nil => false
  validates_uniqueness_of :stock_id
  validates_length_of :company_name, :in => 1..100, :allow_nil => false
  
end
