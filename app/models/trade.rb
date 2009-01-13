class Trade < ActiveRecord::Base
  MAX_SHARES = (10**16)
  MAX_PRICE = (10**7)
  
  belongs_to :trade_order
  
  # trade execution time
  validates_datetime :time,
                      :allow_nil => false
  
  # quantity / number of shares exchanged
  validates_presence_of :quantity,
                        :allow_nil => false
  validates_numericality_of :quantity,
                            :only_integer => true,
                            :greater_than => -MAX_SHARES,
                            :less_than => MAX_SHARES
  
  # trade order id 
  validates_presence_of :trade_order_id,
                        :allow_nil => false
  
  # trade counter-party id                       
  validates_presence_of :counterpart_id,
                        :allow_nil => false
  
  # trading price
  validates_numericality_of :price,
                            :allow_nil => false,
                            :greater_than_or_equal_to => -MAX_PRICE,
                            :less_than_or_equal_to => MAX_PRICE
                            
  validates_format_of :price,
                      :with => /\.\d{0,2}$/
end
