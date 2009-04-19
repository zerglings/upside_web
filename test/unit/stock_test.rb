require 'set'
require 'test_helper'

class StockTest < ActiveSupport::TestCase
  fixtures :markets, :stocks, :positions
  
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
  
  def test_stock_for_finds_existent_stock
    gs = Stock.for_ticker(stocks(:gs).ticker)
    assert_equal stocks(:gs), gs
  end
  
  def test_stock_for_ticker_creates_entry_for_valid_ticker
    assert_nil Stock.find(:first, :conditions => {:ticker => "jpm"})
    count_before = Stock.count
    jpm = Stock.for_ticker("jpm")
    count_after = Stock.count
    assert_equal 1, count_after - count_before
    assert_not_nil Stock.find(:first, :conditions => {:ticker => jpm.ticker})
  end
  
  def test_stock_for_returns_nil_for_invalid_ticker
    count_before = Stock.count
    qwerty = Stock.for_ticker("qwerty")
    count_after = Stock.count
    assert_equal nil, qwerty
    assert_equal 0, count_after - count_before
  end
  
  def test_all_in_positions
    # Create a random stock, so we have at least one dead stock in our db.
    Stock.new(:ticker => 'NOPE', :market => markets(:nyse)).save!

    live_stocks = Set.new([:ms, :gs].map { |sym| stocks sym })
    assert_equal live_stocks, Set.new(Stock.all_in_positions)
  end
end
