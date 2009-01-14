class Position < ActiveRecord::Base
  belongs_to :portfolio
  has_many :stocks
  
  validates_numericality_of :stock_id, :greater_than => 0, :allow_nil => false
  
  validates_numericality_of :portfolio_id, :greater_than => 0, :allow_nil => false
  
  validates_inclusion_of :is_long, :in => [true, false]
  
  validates_numericality_of :quantity, :greater_than => 0
  
  validates_numericality_of :average_base_cost
 
end
