# == Schema Information
# Schema version: 20090728042053
#
# Table name: portfolio_stats
#
#  id           :integer         not null, primary key
#  frequency    :integer(1)      not null
#  portfolio_id :integer(8)      not null
#  net_worth    :decimal(20, 2)  not null
#  rank         :integer(8)
#

class PortfolioStat < ActiveRecord::Base
  belongs_to :portfolio
  validates_presence_of :portfolio, :allow_nil => false
  
  # The statistics' re-computation frequency.
  module Frequencies
    DAILY = 0
    HOURLY = 1
  end  
  validates_inclusion_of :frequency,
                         :in => Frequencies.constants.map { |c|
                              Frequencies.const_get c
                         },
                         :allow_nil => false  
  def frequency_string
    {Frequencies::DAILY => 'daily', Frequencies::HOURLY => 'hourly'}[frequency]    
  end
  
  # The portfolio's net worth, based on cash and positions.
  validates_numericality_of :net_worth, :allow_nil => false,
                            :greater_than_or_equal_to => -Portfolio::MAX_CASH,
                            :less_than_or_equal_to => Portfolio::MAX_CASH,
                            :message => "Cash balance exceeds $10 trillion"
  validates_format_of :net_worth,
                      :with => /\.\d{0,2}$/

  # The portfolio's rank, based on net worth.
  validates_numericality_of :rank, :allow_nil => true, :only_integer => true,
                            :greater_than => 0
                            
  validates_uniqueness_of :frequency, :scope => :portfolio_id

  # Fetches or creates the statistics for a given portfolio and frequency.
  def self.for(portfolio, frequency)
    PortfolioStat.first(:conditions => { :portfolio_id => portfolio.id,
                                         :frequency => frequency }) ||
        PortfolioStat.new(:portfolio => portfolio, :frequency => frequency)
  end
  
  # TODO(overmind): the code below is replicated from Portfolio; clean up 
  
  # Clamps the user's net worth to the storage limits.
  #
  # This is a destructive operation, and should only be performed as a last
  # resort. If clamping actually happens, we have a bug in the economy.
  #
  # This method creates a warning flag if clamping occurs.
  def clamp_net_worth
    return false if net_worth_in_range?
    
    WarningFlag.fatal self, 'Portfolio cash had to be clamped', 1
    self.net_worth = -Portfolio::MAX_CASH if net_worth < -Portfolio::MAX_CASH
    self.net_worth = Portfolio::MAX_CASH if net_worth > Portfolio::MAX_CASH
    true
  end
  
  # True if the user's net worth is within the limits of the storage system.
  def net_worth_in_range?
    net_worth >= -Portfolio::MAX_CASH && net_worth <= Portfolio::MAX_CASH
  end    
end
