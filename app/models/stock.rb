# == Schema Information
# Schema version: 20090728042053
#
# Table name: stocks
#
#  id        :integer         not null, primary key
#  ticker    :string(16)      not null
#  market_id :integer(4)      not null
#

class Stock < ActiveRecord::Base
  belongs_to :market
  has_one :stock_info
  has_many :positions
  
  # The ticker symbol.
  validates_length_of :ticker, :in => 1..10, :allow_nil => false
  validates_uniqueness_of :ticker
  
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
  
  # Retrieves all the stocks that are associated with live positions. 
  def self.all_in_positions
    Stock.find(:all, :joins => [:positions], :group => :id)
  end

  # Clean up an externally received stock price.
  #
  # The returned price is rounded to 2 decimal points.
  def self.clean_price(price)
    (price * 100.0).round / 100.0
  end  
end
