# == Schema Information
# Schema version: 20090703193226
#
# Table name: portfolios
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  cash       :decimal(20, 2)  default(250000.0), not null
#  created_at :datetime
#  updated_at :datetime
#

class Portfolio < ActiveRecord::Base
  MAX_CASH = (10**13 - 0.01)
  NEW_PLAYER_CASH = 250000
  
  belongs_to :user
  has_many :trade_orders, :dependent => :destroy
  has_many :trades, :through => :trade_orders
  has_many :positions
  has_many :stats, :class_name => 'PortfolioStat'
  
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

  # Convenience method for PortfolioStat#for
  def stats_for(frequency)
    PortfolioStat.for self, frequency
  end
    
  # Clamps the user's cash to the storage limits.
  #
  # This is a destructive operation, and should only be performed as a last
  # resort. If clamping actually happens, we have a bug in the economy.
  #
  # This method creates a warning flag if clamping occurs.
  def clamp_cash
    return false if cash_in_range?
    
    WarningFlag.fatal self, 'Portfolio cash had to be clamped', 1
    self.cash = -MAX_CASH if cash < -MAX_CASH
    self.cash = MAX_CASH if cash > MAX_CASH
    true
  end
  
  # True if the user's cash is within the limits of the storage system.
  def cash_in_range?
    cash >= -Portfolio::MAX_CASH && cash <= Portfolio::MAX_CASH
  end  
end

class Portfolio
  # The net worth of all the assets in the portfolio.
  #
  # Assumes stock_spreads contains the spreads for all the portfolio's stocks.
  def net_worth(stock_spreads)
    positions.inject((cash * 100).to_i) { |sum, position|
      sum + (position.net_worth(stock_spreads) * 100).to_i
    } / 100.0
  end
end
