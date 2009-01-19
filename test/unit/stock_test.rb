require 'test_helper'

class StockTest < ActiveSupport::TestCase
  fixtures :markets, :stocks
  
  def setup
    @stock = Stock.new :ticker => "A", :market => markets(:nyse)
  end
  
  def test_stock_validity
    assert @stock.valid?
  end
  
  def test_stock_ticker_cannot_be_null
    @stock.ticker = nil
    assert !@stock.valid?
  end
  
  def test_ticker_length
    @stock.ticker = ""
    assert !@stock.valid?
    @stock.ticker = "A" * 11
    assert !@stock.valid?
  end
  
  def test_ticker_uniqueness
    @stock.ticker = stocks(:gs).ticker
    assert !@stock.valid?
  end
  
  def test_market_id_cannot_be_null
    @stock.market_id = nil
    assert !@stock.valid?
  end
  
  def test_market_id_must_be_positive
    @stock.market_id = 0
    assert !@stock.valid?
    @stock.market_id = -1
    assert !@stock.valid?
  end
  
end
