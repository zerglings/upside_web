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
    fetch_and_parse tickers, 'sdft', 'xab' do |result|
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
    fetch_and_parse(tickers, 'te', 'x', false) { |result| true }
  end
  
  # Determine the markets for stocks
  # Take in array of tickers and returns array of markets
  def self.markets_for_tickers(tickers)
    fetch_and_parse tickers, 'mft', 'x' do |result|
      (result[0].to_s == "N/A") ? :not_found : result[0] 
    end
  end
  
  # Official spreads for the given tickers. Assumes the tickers are valid.
  #
  # This is called very often (once every second) by the trade matcher, and has
  # to process a lot of tickers. The Web service call is optimized to ask for
  # the minimum information needed to do the job, and therefore cannot detect
  # invalid tickers. 
  def self.spreads_for_tickers(tickers)    
    # format: real-time ask and bid, last close, previous day close
    fetch_and_parse tickers, 'sft', 'b2b3l1p', :disable_not_found do |result|
      ask, bid = result[0].to_f, result[1].to_f
      closing = result[2].to_f
      closing = result[3].to_f if closing == 0
      # If there's no real bid / ask, simulate some.
      bid = Stock.clean_price(closing * 0.98) if bid == 0
      ask = Stock.clean_price(closing * 1.02) if ask == 0
      { :ask => ask, :bid => bid, :close => Stock.clean_price(closing) }
    end
  end
  
  # TODO(overmind): spec this
  def self.fetch_and_parse(tickers, cache_id, data_codes,
                           not_found_placeholder = :not_found, &block)
    cached_answer = StockCacheLine.cache_fetch tickers, cache_id
    
    # Fetch live answer for un-cached tickers from Yahoo.
    missed_tickers = tickers.reject { |ticker| cached_answer.has_key? ticker }
    live_answer = fetch_and_parse_without_cache! missed_tickers, data_codes,
                                                 not_found_placeholder, &block
    # Update the cache.
    cache_lines = StockCacheLine.lines_for missed_tickers, cache_id
    missed_tickers.each_with_index do |ticker, index|
      cache_lines[ticker] ||= StockCacheLine.new :ticker => ticker,
                                                 :info_type => cache_id
      cache_lines[ticker].value = live_answer[index]
    end    
    # TODO(overmind): investigate bulk-saving
    cache_lines.each { |ticker, line| line.save! }
                                                 
    answer = []
    i = 0
    tickers.each do |ticker|
      if cached_answer.has_key? ticker
        answer << cached_answer[ticker]
      else
        answer << live_answer[i]
        i += 1
      end
    end
    answer
  end

  # TODO(overmind): spec this
  def self.fetch_and_parse_without_cache!(tickers, data_codes,
                                          not_found_placeholder = :not_found,
                                          &block)
    max_tickers = 150  # Yahoo will crash if we ask for more than 200 tickers
    i = 0
    answer = []
    while i < tickers.length
      round_tickers = tickers[i, max_tickers]
      response = fetch_data(round_tickers, data_codes)
      answer_chunk = parse_response response, not_found_placeholder, &block 
      i += answer_chunk.length
      answer += answer_chunk
    end
    answer
  end
    
  # Generic method for pulling information from Yahoo finance.
  def self.fetch_data(tickers, data_codes)
    # TODO(overmind): we should ensure that we don't get garbage in our system,
    #                 instead of filtering it here
    ticker_string = tickers.map { |t| t.gsub('_', ' ') }.join("+")
    query = "/d/?s=#{URI.encode(ticker_string)}&f=#{data_codes}"
    
    response = Net::HTTP.start "download.finance.yahoo.com", 80 do |http|
      http.get query
    end
    unless response.kind_of? Net::HTTPSuccess
      raise "Failed to pull Yahoo stock data - #{response.inspect}"
    end
    return response.body
  end

  # Generic parser for data returned from Yahoo finance.
  # Assumes the first column for each stock is N/A if the stock does not exist.
  def self.parse_response(response, not_found_placeholder = :not_found)
    results = CSV.parse response
    results.map do |result|
      if not_found_placeholder != :disable_not_found && result.first == "N/A"
        next not_found_placeholder
      end
      yield result
    end
  end  
end

if __FILE__ == $0
  p YahooFetcher.fetch_data(["GOOG","XXXX","MSFT","ZZZZ"])
  p YahooFetcher.stock_data_for_tickers(["GOOG","XXXX","MSFT","ZZZZ"])
end
