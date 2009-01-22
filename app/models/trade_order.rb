class TradeOrder < ActiveRecord::Base
  MAX_PRICE_PER_SHARE = (10**6 -0.01)
  MAX_QUANTITY_SHARES_PER_TRADE = (10**16)
  
  belongs_to :portfolio
  belongs_to :stock
  has_many :trades
  has_one :order_cancellation, :dependent => :destroy
  
  # portfolio id 
  validates_presence_of :portfolio_id
  
  # stock id
  validates_presence_of :stock_id
                        
  # buy / sell
  validates_inclusion_of :is_buy,
                         :in => [true, false],
                         :message => 'is_buy must be specified'
                        
  # long / short
  validates_inclusion_of :is_long,
                         :in => [true, false],
                         :message => 'is_long must be specified'
                        
  # stop price and limit price
  [:stop_price, :limit_price].each do |field|
    validates_numericality_of field,
                              :greater_than_or_equal_to => -MAX_PRICE_PER_SHARE,
                              :less_than_or_equal_to => MAX_PRICE_PER_SHARE,
                              :allow_nil => true   
    
    validates_format_of field,
                        :with => /\.\d{0,2}$/,
                        :allow_nil => true
  end
  
  # expiration time of trade order
  validates_datetime :expiration_time,
                     :allow_nil => true,
                     :after => Proc.new { Time.now }
                     
  # number of shares to be traded
  validates_presence_of :quantity,
                        :allow_nil => false,
                        :message => "Must enter desired number of shares to be traded."
  
  validates_numericality_of :quantity,
                            :only_integer => true,
                            :greater_than => 0,
                            :less_than => MAX_QUANTITY_SHARES_PER_TRADE
end

# Virtual attributes for display

class TradeOrder
  # virtual attribute to convert stock ticker to stock_id        
  attr_reader :ticker
  
  def ticker=(stock_ticker)
    @ticker = stock_ticker
    
    stock = Stock.find(:first, 
               :conditions => {:ticker => @ticker})
    self.stock_id = stock.id
  end
  
  # virtual attribute to determine order type (market order or limit order)
  def is_limit
    (limit_price || stop_price) ? true : false
  end
  
  def is_limit=(new_limit)
    # fake setter so submitting forms works
  end
  
  # Trade order transaction type
  def transaction_type    
    if is_buy == true && is_long == false 
      return "Short"
    elsif is_buy == true && is_long == true  
      return "Buy"
    elsif is_buy == false && is_long == false
      return "Buy to Cover"
    elsif is_buy == false && is_long == true
      return "Sell"
    else
      return nil
    end  
  end
end
