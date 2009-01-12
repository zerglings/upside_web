class Position < ActiveRecord::Base
  belongs_to :position
  
  validates_numericality_of :stock_id,
                            :greater_than => 0,
                            :allow_nil => false
  validates_numericality_of :portfolio_id,
                            :greater_than => 0,
                            :allow_nil => false
  validates_presence_of :is_long?
  validates_presence_of :quantity
  validates_presence_of :average_base_cost
 
end
