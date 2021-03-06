require 'test_helper'
require 'flexmock/test_unit'

class YahooFetcherTest < ActiveSupport::TestCase
  fixtures :stock_cache_lines
  
  def setup
    super
    @tickers = ["GOOG","XXXX","MSFT"]
  end
  
  def test_fetch_data
    fetched_data = YahooFetcher.fetch_data @tickers, "xab"
    assert_not_nil fetched_data, "No data was fetched"
  end
  
  def test_stock_data_for_tickers
    parsed_data = YahooFetcher.stock_data_for_tickers @tickers
    assert_equal @tickers.length, parsed_data.length, "Incorrect data fetched"
  end
  
  def test_pull_yahoo_data_without_tickers_fails
    assert_raise(NoMethodError) do
      fetched_data = YahooFetcher.fetch_data nil, "x"
    end
  end
  
  def test_parse_response
    fetched_data = <<END
"NasdaqNM",N/A,312.50
"N/A",N/A,N/A
"NasdaqNM",N/A,19.03
"AMEX",N/A,N/A
END

    flexmock(YahooFetcher).should_receive(:fetch_data).with_any_args.
                           and_return(fetched_data)

    golden_tickers =
        [{:ask => 0.0, :bid => 312.50, :stock_exchange => "NasdaqNM"},
         :not_found,
         {:ask => 0.0, :bid => 19.03, :stock_exchange => "NasdaqNM"},
         {:ask => 0.0, :bid => 0.0, :stock_exchange => "AMEX"}]

    tickers = YahooFetcher.stock_data_for_tickers ["S1", "S2", "S3", "S4"]
    
    assert_equal golden_tickers, tickers
  end
  
  def test_tickers_exist
    assert_equal [true, false, true, true],
                 YahooFetcher.tickers_exist?(["GOOG", "XXXX", "MSFT", "ZZZZ"])     
  end
  
  def test_markets_for_tickers_works_for_several_tickers
    markets_array = YahooFetcher.markets_for_tickers(["mrk", "qwerty","cvs"])
    assert_equal ["NYSE", :not_found, "NYSE"], markets_array
  end
  
  def test_spreads_for_tickers_parsing
    fetched_data = <<END
96.27,0.00,91.51,90.13
N/A,N/A,0.00,0.00
0.00,330.15,0.00,338.5301
18.00,17.05,17.83,17.10
END
    flexmock(YahooFetcher).should_receive(:fetch_data).with_any_args.
                           and_return(fetched_data)

    tickers = ['AAPL', 'XXXX', 'CSCO', 'MSFT']
    golden_spreads = [{:ask => 96.27, :bid => 89.68, :close => 91.51},
                      {:ask => 0.0, :bid => 0.0, :close => 0.0},
                      {:ask => 345.30, :bid => 330.15, :close => 338.53},
                      {:ask => 18.00, :bid => 17.05, :close => 17.83}]
    assert_equal golden_spreads, YahooFetcher.spreads_for_tickers(tickers)
  end
  
  def test_spreads_for_tickers_live
    tickers = ['AAPL', 'CSCO', 'MSFT']    
    spreads = YahooFetcher.spreads_for_tickers(tickers)
    assert_equal 3, spreads.length
    spreads.each_with_index do |spread, index|
      assert spread[:ask] > 0.0, "Zero ask in spread for #{tickers[index]}"
      assert spread[:bid] > 0.0, "Zero bid in spread for #{tickers[index]}"
    end
  end
  
  def test_caching
    fetched_data = <<END
96.27,0.00,91.51,90.13
18.00,17.05,17.83,17.10
END

    tickers = ['AAPL', 'GOOG', 'MSFT', 'YHOO']
    flexmock(YahooFetcher).should_receive(:fetch_data).once.
                           with(['AAPL', 'MSFT'], 'b2b3l1p').
                           and_return(fetched_data)
    
    golden_spreads = [{:ask => 96.27, :bid => 89.68, :close => 91.51},
                      {:ask => 365, :bid => 360, :close => 362},
                      {:ask => 18.00, :bid => 17.05, :close => 17.83},
                      {:ask => 20, :bid => 10, :close => 15}]
    assert_equal golden_spreads, YahooFetcher.spreads_for_tickers(tickers),
                 'Cache hits and misses'

    assert_equal golden_spreads, YahooFetcher.spreads_for_tickers(tickers),
                 '100% cache hits'
  end
end
