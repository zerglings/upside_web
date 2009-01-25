require 'net/https'
require 'uri'
require 'csv'

module YahooFetcher
  # Pulls and returns stock data from Yahoo finance.
  #  Parameters:
  #    tickers: an array of stock tickers 
  #      ex. ["GOOG","MSFT"]
  #  Returns:
  #    an array of hashes with each hash accounting for one of the stock tickers  
  #    ex. [{:ask=>316.18, :bid=>315.0}, {:ask=>19.6, :bid=>19.58}]
  def self.stock_data_for_tickers(tickers)
    parse_response fetch_data(tickers, "xab") do |result|
      { :stock_exchange => result[0],
        :ask => result[1].to_f,
        :bid => result[2].to_f
      }
    end
  end
  
  # Checks the existence of ticker symbols with Yahoo finance.
  #  Parameters:
  #   tickers: an array of stock tickers 
  #      ex. ["GOOG","MSFT"]
  #  Returns:
  #   an array with a boolean per ticker (true = exists, false = does not exist)
  def self.tickers_exist?(tickers)
    parse_response(fetch_data(tickers, "x"), false) { |result| true }
  end
  
  # Determine the markets for stocks
  # Take in array of tickers and returns array of markets
  def self.markets_for_tickers(tickers)
    parse_response fetch_data(tickers, "x") do |result|
      (result[0].to_s == "N/A") ? :not_found : result[0] 
    end
  end
  
  # Generic method for pulling information from Yahoo finance.
  def self.fetch_data(tickers, data_codes)
    query = "/d/?s=#{URI.encode(tickers.join("+"))}&f=#{data_codes}"
    
    response = Net::HTTP.start("download.finance.yahoo.com", 80) { |http| http.get query}
    unless response.kind_of? Net::HTTPSuccess
      raise "Failed to pull Yahoo stock data - #{response.inspect}"
    end
    return response.body
  end

  # Generic parser for data returned from Yahoo finance.
  # Assumes the first column for each stock is N/A if the stock does not exist.
  def self.parse_response(response, not_found_placeholder = :not_found)
    results = CSV.parse(response)
 
    results.map do |result|
      next not_found_placeholder if result.first == "N/A"      
      yield result
    end 
  end
end

if __FILE__ == $0
  p YahooFetcher.fetch_data(["GOOG","XXXX","MSFT","ZZZZ"])
  p YahooFetcher.stock_data_for_tickers(["GOOG","XXXX","MSFT","ZZZZ"])
end
