require 'test_helper'

class StockCacheLineTest < ActiveSupport::TestCase
  def setup
    @cache_line = StockCacheLine.new :ticker => 'AAPL', :info_type => 'sft',
                                     :value => { :ask => 100, :bid => 101,
                                                 :close => 100.5 }
  end
  
  def test_validity
    assert @cache_line.valid?
  end
  
  def test_ticker_cannot_be_nil
    @cache_line.ticker = nil
    assert !@cache_line.valid?
  end

  def test_ticker_length
    @cache_line.ticker = 'A' * 11
    assert !@cache_line.valid?
  end

  def test_info_type_cannot_be_nil
    @cache_line.info_type = nil
    assert !@cache_line.valid?
  end

  def test_info_type_length
    @cache_line.info_type = 'A' * 9
    assert !@cache_line.valid?
  end

  def test_cache_fetch
    lines = StockCacheLine.cache_fetch ['AAPL', 'GOOG', 'MSFT', 'YHOO'], 'sft'    
    golden_lines = {'GOOG' => {:ask => 365, :bid => 360, :close => 362},
                    'YHOO' => {:ask => 20, :bid => 10, :close => 15}} 
    assert_equal golden_lines, lines
  end
  
  def test_lines_for    
    lines = StockCacheLine.lines_for ['AAPL', 'GOOG', 'MSFT', 'YHOO'], 'sft'
    golden_lines =
        {'GOOG' => stock_cache_lines(:google_spread_for_tickers),
         'MSFT' => stock_cache_lines(:microsoft_expired_spread_for_tickers),
         'YHOO' => stock_cache_lines(:yahoo_spread_for_tickers)} 
    assert_equal golden_lines, lines
  end
end
