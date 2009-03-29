# == Schema Information
# Schema version: 20090120032718
#
# Table name: trades
#
#  id             :integer(4)      not null, primary key
#  time           :datetime        not null
#  quantity       :integer(4)      not null
#  trade_order_id :integer(4)      not null
#  counterpart_id :integer(4)
#  price          :decimal(8, 2)   not null
#  created_at     :datetime
#

class Trade < ActiveRecord::Base
  include ModelLimits
  
  belongs_to :trade_order
  
  # trade execution time
  validates_datetime :time,
                     :allow_nil => false
  
  # quantity / number of shares exchanged
  validates_presence_of :quantity,
                        :allow_nil => false
  validates_numericality_of :quantity,
                            :only_integer => true,
                            :greater_than => 0,
                            :less_than => MAX_QUANTITY_SHARES_PER_TRADE
  
  # trade order id 
  validates_numericality_of :trade_order_id,
                            :only_integer => true,
                            :greater_than => 0,
                            :allow_nil => false
  
  # trade order id of counter-party                      
  validates_numericality_of :counterpart_id,
                            :only_integer => true,
                            :allow_nil => true
  
  # price per share
  validates_numericality_of :price,
                            :allow_nil => false,
                            :greater_than => 0,
                            :less_than_or_equal_to => MAX_PRICE_PER_SHARE
                            
  validates_format_of :price,
                      :with => /\.\d{0,2}$/,
                      :allow_nil => false
  
  def portfolio
    trade_order.portfolio
  end
  
  def execute
    Trade.transaction do
      execute_without_transaction!
    end
  end
  
  def execute_without_transaction!
    portfolio = trade_order.portfolio    
    position = Position.find(:first, :conditions => {:portfolio_id => trade_order.portfolio_id,
                                                     :stock_id => trade_order.stock_id,
                                                     :is_long => trade_order.is_long})
    if position
      adjust_position_quantity!(position)
      adjust_position_average_base_cost!(position)
    else
      position = Position.new(:portfolio_id => trade_order.portfolio_id,
                              :stock_id => trade_order.stock_id, 
                              :is_long => trade_order.is_long,
                              :quantity => quantity,
                              :average_base_cost => price)
    end
    adjust_portfolio_cash! portfolio
    position.save!
    portfolio.save!
    
    trade_order.unfilled_quantity -= quantity
    trade_order.save!
  end
  private :execute_without_transaction!
  
  # private methods below
  def adjust_position_quantity!(position)
    position.quantity += if trade_order.is_long? == trade_order.is_buy?
      quantity
    else
      -quantity
    end
  end
  private :adjust_position_quantity!
  
  def adjust_portfolio_cash!(portfolio)
    cash_delta = quantity * price
    cash_delta = -cash_delta if trade_order.is_buy?
    portfolio.cash += cash_delta
  end
  private :adjust_portfolio_cash!
  
  def adjust_position_average_base_cost!(position)
    # TODO(nightshade): implement and test average base price
  end
  private :adjust_position_average_base_cost!
  
end
