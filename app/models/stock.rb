class Stock < ActiveRecord::Base
  belongs_to :market
  has_one :stock
    
  validates_uniqueness_of :ticker, :allow_nil => false
  validates_length_of :ticker, :in => 1..10
  
  validates_numericality_of :market_id, :greater_than => 0, :allow_nil => false
  
  def self.find_stock_by_ticker(ticker)
    find(:first, :conditions => "ticker = ticker")
  end
  
  def self.find_all_stocks_for_market_id(m_ID)
    find(:all, :conditions => "market_id = m_ID")
  end
  
end
