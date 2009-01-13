require 'test_helper'

class StockTest < ActiveSupport::TestCase
  
  fixtures :stocks
  
  def setup
    @stock = Stock.new(:ticker => "A", :market_id => 2)
  end
  
  def test_stock_validity
    assert @stock.valid?
  end
  
  def test_stock_ticker_presence
    @stock.ticker = nil
    assert !@stock.valid?
  end
  
  def test_stock_ticker_length
    @stock.ticker = ""
    assert !@stock.valid?
    @stock.ticker = "12345678910"
    assert !@stock.valid?
  end
  
  def test_stock_ticker_uniqueness
    @stock.ticker = "GS"
    assert !@stock.valid?
  end
  
  def test_stock_market_id_presence
    @stock.market_id = nil
    assert !@stock.valid?
  end
  
  def test_stock_market_id_numericality
    @stock.market_id = 0
    assert !@stock.valid?
    @stock.market_id = -1
    assert !@stock.valid?
  end
  
end
