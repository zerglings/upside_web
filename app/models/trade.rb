class Trade < ActiveRecord::Base
  
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
                            :less_than => TradeOrder::MAX_QUANTITY_SHARES_PER_TRADE
  
  # trade order id 
  validates_presence_of :trade_order_id,
                        :allow_nil => false
  
  # trade order id of counter-party                      
  validates_numericality_of :counterpart_id,
                        :allow_nil => true
  
  # price per share
  validates_numericality_of :price,
                            :allow_nil => false,
                            :greater_than => 0,
                            :less_than_or_equal_to => TradeOrder::MAX_PRICE_PER_SHARE
                            
  validates_format_of :price,
                      :with => /\.\d{0,2}$/,
                      :allow_nil => false
end
