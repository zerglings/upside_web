# == Schema Information
# Schema version: 20090409160908
#
# Table name: stocks
#
#  id        :integer(4)      not null, primary key
#  ticker    :string(16)      not null
#  market_id :integer(4)      not null
#

class Stock < ActiveRecord::Base
  belongs_to :market
  has_one :stock_info
    
  validates_uniqueness_of :ticker, :allow_nil => false
  validates_length_of :ticker, :in => 1..10
  
  validates_numericality_of :market_id, :greater_than => 0, :allow_nil => false
  
  def self.for_ticker(ticker)
    stock = Stock.find(:first, 
                       :conditions => {:ticker => ticker})
   
    if stock.nil?
      market_name = YahooFetcher.markets_for_tickers([ticker]).first
      if market_name != :not_found
        market = Market.for_name(market_name)
        stock = Stock.new(:ticker => ticker, :market => market)
        stock.save!    
      end
    end 
    
    return stock
  end
end
