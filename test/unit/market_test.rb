require 'test_helper'

class MarketTest < ActiveSupport::TestCase

  def setup
    @market = Market.new(:name => "NASDAQ")
  end
  
  def test_validity
    assert @market.valid?
  end
  
  def test_name_length
    @market.name = "ha"
    assert !@market.valid?
    @market.name = "hah"
    assert @market.valid?
    @market.name = "NASDAQ" * 10 + "NASDA"
    assert !@market.valid?
  end
  
  def test_name_presence
    @market.name = nil
    assert !@market.valid?
  end
  
  def test_for_name_finds_existent_market
    nyse = Market.for_name(markets(:nyse).name)
    assert_equal markets(:nyse), nyse
  end
  
  def test_For_name_creates_entry_for_valid_market
    count_before = Market.count
    amex = Market.for_name("amex")
    count_after = Market.count
    assert_equal 1, count_after - count_before
    assert_not_nil Market.find(:first, :conditions => {:name => "amex"})
  end
end
