class Position < ActiveRecord::Base
  belongs_to :portfolio
  belongs_to :stock

  # The stock held in this position.
  validates_numericality_of :stock_id, :greater_than => 0, :allow_nil => false
  
  # The portfolio containing this position.
  validates_numericality_of :portfolio_id, :greater_than => 0, :allow_nil => false
  
  # The number of stocks in this position.
  validates_numericality_of :quantity, :greater_than => 0, :allow_nil => false
  
  # The average base cost of this position.
  # We haven't quite decided what this means yet.
  validates_numericality_of :average_base_cost, :allow_nil => false
  
  # True for long positions, false for shorts.
  validates_inclusion_of :is_long, :in => [true, false], :allow_nil => false
  validates_uniqueness_of :is_long, :scope => [:portfolio_id, :stock_id]
end
