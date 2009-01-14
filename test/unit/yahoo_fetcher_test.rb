require 'test_helper'

class YahooFetcherTest < ActiveSupport::TestCase
  def test_pull_Yahoo_data
    @tickers = ["GOOG","XXXX","MSFT"]
    fetched_data = YahooFetcher.fetch_data(@tickers)
    assert_not_nil fetched_data, "No data was fetched"
    parsed_data = YahooFetcher.parse_response(fetched_data)
    assert_equal @tickers.length, parsed_data.length, "Incorrect data fetched"
  end
  
  def test_pull_Yahoo_data_without_tickers_fails
    @tickers = nil
    assert_raise(NoMethodError) do
      fetched_data = YahooFetcher.fetch_data(@tickers)
    end
  end
  
  def test_parse_csv_to_hash
    fetched_data = <<END
N/A,312.50,"NasdaqNM"
N/A,N/A,"N/A"
N/A,19.03,"NasdaqNM"
N/A,N/A,"AMEX"
END
    golden_tickers = [{:ask => 0.0, :bid => 312.50, :stock_exchange => "NasdaqNM"},
    :not_found,
    {:ask => 0.0, :bid => 19.03, :stock_exchange => "NasdaqNM"},
    {:ask => 0.0, :bid => 0.0, :stock_exchange => "AMEX"}]

    tickers = YahooFetcher.parse_response fetched_data
    
    assert_equal golden_tickers, tickers    
  end
end