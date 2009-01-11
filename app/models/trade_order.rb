class TradeOrder < ActiveRecord::Base
  belongs_to :portfolio
  has_many :trades
  
  # portfolio id 
  validates_presence_of :portfolio_id,
                        :allow_nil => false
  
  # stock id
  validates_presence_of :stock_id,
                        :allow_nil => false
                        
  # buy / sell
  validates_inclusion_of :is_buy,
                         :in => [true, false],
                         :message => 'Is_buy boolean should be true or false'
                        
  # long / short
  validates_inclusion_of :is_long,
                         :in => [true, false],
                         :message => 'Is_long boolean should be true or false'
                        
  # stop price and limit price
  [:stop_price, :limit_price].each do |field|
  validates_numericality_of field,
                            :greater_than_or_equal_to => -(10**6 - 0.01),
                            :less_than_or_equal_to => (10**6 - 0.01),
                            :allow_nil => true   
  
  validates_format_of field,
                      :with => /\.\d{0,2}$/
  end
  
  # expiration time of trade order
  validates_date_time :expiration_time,
                      :allow_nil => true,
                      :after => Proc.new { Time.now }
end
