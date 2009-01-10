require 'net/https'
require 'uri'
require 'csv'

# Pulls stock information from Yahoo Finance
#  Parameter:
#    search_stock_data takes in an array of stock tickers 
#    ex. ["GOOG","MSFT"] 
#
#  Output:
#    an array of hashes with each hash accounting for one of the stock tickers  
#    ex. [{:ask=>316.18, :bid=>315.0}, {:ask=>19.6, :bid=>19.58}]


module YahooFetcher
  def self.search_stock_data(tickers)
    data_csv = fetch_yahoo_data(tickers)
    data_parsed = parse_response(data_csv)
  end

#  Yahoo uses different codes to pull data for stock tickers ("a" = Ask, "e" = Earnings per share, etc.)
#  Tickers are entered into an array and then joined with "+"
#  The output of fetching Yahoo data is a CSV document with each company on a separate line  
  def self.fetch_yahoo_data(tickers)
    data_codes = "ab"
    
    query = "/d/?s=#{URI.encode(tickers.join("+"))}&f=#{URI.encode(data_codes)}"
    
    response = Net::HTTP.start("download.finance.yahoo.com", 80) { |http| http.get query}
    unless response.kind_of? Net::HTTPSuccess
      raise "Failed to pull Yahoo stock data - #{response.inspect}"
    end
    return response.body
  end

# The CSV file outputted from above is now parsed and converted into an array of hashes  
  def self.parse_response(response)
    results = CSV.parse(response)
 
    results.map do |result|
      { :ask => result[0].to_f,
        :bid => result[1].to_f
      }
    end 
  end
end

# p YahooFetcher.search_stock_data(["GOOG","MSFT"])
