# == Schema Information
# Schema version: 20090424025419
#
# Table name: positions
#
#  id                :integer(4)      not null, primary key
#  portfolio_id      :integer(4)      not null
#  stock_id          :integer(4)      not null
#  is_long           :boolean(1)      not null
#  quantity          :integer(4)      not null
#  average_base_cost :float
#  decimal           :float
#  created_at        :datetime
#  updated_at        :datetime
#

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

class Position
  # The net worth of this position.
  #
  # Assumes stock_spreads contains the spread for this position's stock.
  def net_worth(stock_spreads)
    absolute_worth = stock_spreads[stock][:close] * quantity
    is_long ? absolute_worth : -absolute_worth
  end
end
