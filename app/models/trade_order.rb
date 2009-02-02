class TradeOrder < ActiveRecord::Base
  include ModelLimits
  
  belongs_to :portfolio
  belongs_to :stock
  has_many :trades
  has_one :order_cancellation, :dependent => :destroy
  
  # portfolio id 
  validates_presence_of :portfolio_id
  
  # stock id
  validates_presence_of :stock_id, 
                        :message => "Please enter a valid ticker."
                        
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
                              :greater_than => 0,
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
                            
  # number of shares that still need to be traded as part of this order
  attr_protected :unfilled_quantity
  validates_numericality_of :unfilled_quantity,
                            :only_integer => true,
                            :greater_than_or_equal_to => 0,
                            :allow_nil => false
  validates_each :unfilled_quantity do |order, attr, value|
    next if order.unfilled_quantity.nil? or order.quantity.nil?
    next unless order.unfilled_quantity > order.quantity
    order.errors.add attr, 'Shares unfilled cannot exceed total shares.'
  end

  # override quantity assignment to set unfilled_quantity
  def quantity=(new_quantity)
    super
    self.unfilled_quantity = new_quantity    
  end
  
  # true if this order has been filled
  def filled?()
    unfilled_quantity == 0
  end                            
end

# Virtual attributes for display

class TradeOrder
  # virtual attribute to convert stock ticker to stock_id        
  attr_reader :ticker
  
  def ticker=(stock_ticker)
    @ticker = stock_ticker    
    self.stock = Stock.for_ticker(stock_ticker)
  end
  
  # virtual attribute to determine order type (market order or limit order)
  def is_limit
    (limit_price || stop_price) ? true : false
  end
  alias_method :is_limit?, :is_limit
  
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
