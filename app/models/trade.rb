class Trade < ActiveRecord::Base
  
  belongs_to :trade_order
  
  after_save :execute
  
  # trade execution time
  validates_datetime :time,
                      :allow_nil => false
  
  # quantity / number of shares exchanged
  validates_presence_of :quantity,
                        :allow_nil => false
  validates_numericality_of :quantity,
                            :only_integer => true,
                            :greater_than => 0,
                            :less_than => TradeOrder::MAX_QUANTITY_SHARES_PER_TRADE
  
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
                            :less_than_or_equal_to => TradeOrder::MAX_PRICE_PER_SHARE
                            
  validates_format_of :price,
                      :with => /\.\d{0,2}$/,
                      :allow_nil => false
  
  def portfolio
    trade_order.portfolio
  end
  
  # private methods below
  private
  
  def execute
    position = Position.find(:first, :conditions => {:portfolio_id => trade_order.portfolio_id,
                                                      :stock_id => trade_order.stock_id,
                                                      :is_long => trade_order.is_long})
    if position
      adjust_position_quantity(position)
      adjust_position_average_base_cost(position)
    else
      position = Position.new(:portfolio_id => trade_order.portfolio_id,
                              :stock_id => trade_order.stock_id, 
                              :is_long => trade_order.is_long,
                              :quantity => quantity,
                              :average_base_cost => 0)
    end
    position.save!
  end
  
  def adjust_position_quantity(position)
    if trade_order.is_buy?
      position.quantity += quantity
    end
    if !trade_order.is_buy?
      position.quantity -= quantity
    end
  end
  
  def adjust_position_average_base_cost(position)
    
  end
  
end
