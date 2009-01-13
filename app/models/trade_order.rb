class TradeOrder < ActiveRecord::Base
  MAX_PRICE_PER_SHARE = (10**6 -0.01)
  MAX_QUANTITY_SHARES_PER_TRADE = (10**16)
  
  belongs_to :portfolio
  has_many :trades, :dependent => :nullify
  
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
                        :allow_nil => false
  
  validates_numericality_of :quantity,
                            :only_integer => true,
                            :greater_than => 0,
                            :less_than => MAX_QUANTITY_SHARES_PER_TRADE
end
