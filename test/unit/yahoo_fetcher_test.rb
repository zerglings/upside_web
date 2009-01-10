require 'test_helper'

class YahooFetcherTest < ActiveSupport::TestCase
  def test_pull_Yahoo_data
    @tickers = ["GOOG","MSFT"]
    fetched_data = YahooFetcher.fetch_yahoo_data(@tickers)
    assert_not_nil fetched_data, "No data was fetched"
    parsed_data = YahooFetcher.parse_response(fetched_data)
    assert_equal @tickers.length, parsed_data.length, "Incorrect data fetched"
  end
  
  # pulling data with incorrect tickers will return a row with 0's
  def test_pull_Yahoo_data_with_incorrect_tickers
    @tickers = ["ZZZZ"]
    fetched_data = YahooFetcher.fetch_yahoo_data(@tickers)
    assert_not_nil fetched_data
  end
  
  def test_pull_Yahoo_data_without_tickers_fails
    @tickers = nil
    assert_raise(NoMethodError) do
      fetched_data = YahooFetcher.fetch_yahoo_data(@tickers)
    end
  end
  
  def test_parse_csv_to_hash
    fetched_data = <<END
315.71,314.70
19.59,19.56
END
    golden_tickers = [{:ask => 315.71, :bid => 314.70},
    {:ask => 19.59, :bid => 19.56}]

    tickers = YahooFetcher.parse_response fetched_data
    
    assert_equal golden_tickers, tickers    
  end
end