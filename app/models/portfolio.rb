class Portfolio < ActiveRecord::Base
  MAX_CASH = (10**13 -0.01)
  
  belongs_to :user
  # has_many :trade_orders, :dependent => :destroy
  
  # user id
  validates_presence_of :user_id   
  validates_uniqueness_of :user_id
  
  # cash balance
  validates_numericality_of :cash,
                            :allow_nil => false,
                            :greater_than_or_equal_to => -MAX_CASH,
                            :less_than_or_equal_to => MAX_CASH,
                            :message => "Cash balance exceeds $10 billion"
  validates_format_of :cash,
                      :with => /\.\d{0,2}$/
                                    
end
