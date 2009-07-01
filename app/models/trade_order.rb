# == Schema Information
# Schema version: 20090701053535
#
# Table name: trade_orders
#
#  id                 :integer(4)      not null, primary key
#  portfolio_id       :integer(8)      not null
#  stock_id           :integer(4)      not null
#  is_buy             :boolean(1)      default(TRUE), not null
#  is_long            :boolean(1)      default(TRUE), not null
#  stop_price         :decimal(8, 2)
#  limit_price        :decimal(8, 2)
#  expiration_time    :datetime
#  quantity           :integer(8)      not null
#  unfilled_quantity  :integer(8)      not null
#  created_at         :datetime
#  updated_at         :datetime
#  adjusting_order_id :integer(8)
#  client_nonce       :string(32)
#

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
  
  # client nonce
  validates_length_of :client_nonce, :in=> 1..32, :allow_nil => true
  validates_uniqueness_of :client_nonce, :scope => :portfolio_id,
                          :allow_nil => true  
  
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
  
  # the order that is adjusted by this order
  belongs_to :adjusting_order, :class_name => 'TradeOrder',
             :foreign_key => 'adjusting_order_id'
  validates_presence_of :adjusting_order,
                        :if => lambda { |o| o.adjusting_order_id }
  

  # override quantity assignment to set unfilled_quantity
  def quantity=(new_quantity)
    super
    self.unfilled_quantity = new_quantity    
  end
  
  # true if this order has been filled
  def filled?()
    unfilled_quantity == 0
  end
  
  # The position that should be impacted by this trade order.
  #
  # :call-seq:
  #   trade_order.target_position -> Position
  #
  # The position is looked up in the database. If no position exists, a dummy
  # position is created with 0 stocks. The dummy position is a new record, and
  # it will not be saved if you don't take specific measures to ensure that.
  #
  # For testing purposes, you can use Position#new_record? to verify if the
  # position returned by this method exists in the database.
  def target_position
    Position.find(:first, :conditions => { :portfolio_id => portfolio_id,
                                           :stock_id => stock_id,
                                           :is_long => is_long }) ||    
        Position.new(:portfolio_id => portfolio_id,
                     :stock_id => stock_id,
                     :is_long => is_long,
                     :quantity => 0,
                     :average_base_cost => 0)    
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
