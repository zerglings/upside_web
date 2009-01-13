class Position < ActiveRecord::Base
  belongs_to :position
  
  validates_numericality_of :stock_id, :greater_than => 0, :allow_nil => false
  
  validates_numericality_of :portfolio_id, :greater_than => 0, :allow_nil => false
  
  validates_inclusion_of :is_long?, :in => [true, false]
  
  validates_presence_of :quantity
  
  validates_presence_of :average_base_cost
  
  def self.find_all_positions_for_portfolio(pf_ID)
    find(:all, :conditions => "portfolio_id = pf_ID")
  end
  
  def self.find_all_long_positions
    find(:all, :conditions => "is_long? = true")
  end
  
  def self.find_all_short_positions
    find(:all, :conditions => "is_long? = false")
  end
 
end
