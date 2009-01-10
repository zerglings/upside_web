require 'net/https'
require 'uri'
require 'csv'

module YahooFetcher
  def self.stock_data_for_tickers(tickers)
    data_csv = fetch_data(tickers)
    data_parsed = parse_response(data_csv)
  end

  # Pulls and returns stock data from Yahoo finance
  #  Parameters:
  #    different codes to pull data for stock tickers 
  #      ex. "a" = Ask, "e" = Earnings per share, etc.
  #    an array of stock tickers 
  #      ex. ["GOOG","MSFT"] 
  #  Output:
  #    CSV document with each company's data on a separate line  
  def self.fetch_data(tickers)
    data_codes = "abx"
    
    query = "/d/?s=#{URI.encode(tickers.join("+"))}&f=#{URI.encode(data_codes)}"
    
    response = Net::HTTP.start("download.finance.yahoo.com", 80) { |http| http.get query}
    unless response.kind_of? Net::HTTPSuccess
      raise "Failed to pull Yahoo stock data - #{response.inspect}"
    end
    return response.body
  end

  # The CSV file outputted from above is now parsed and converted into 
  #    an array of hashes with each hash accounting for one of the stock tickers  
  #    ex. [{:ask=>316.18, :bid=>315.0}, {:ask=>19.6, :bid=>19.58}]  
  def self.parse_response(response)
    print response
    results = CSV.parse(response)
 
    results.map do |result|
      if result[2] != "N/A"
      { :ask => result[0].to_f,
        :bid => result[1].to_f,
        :stock_exchange => result[2]
      }
      else
        :not_found
      end
    end 
  end
end
 p YahooFetcher.fetch_data(["GOOG","XXXX","MSFT","ZZZZ"])
 p YahooFetcher.stock_data_for_tickers(["GOOG","XXXX","MSFT","ZZZZ"])
