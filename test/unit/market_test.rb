require 'test_helper'

class MarketTest < ActiveSupport::TestCase

  def setup
    @market = Market.new(:name => "NASDAQ")
  end
  
  def test_market_name_length
    assert @market.valid?
    
    @market.name = "ha"
    assert !@market.valid?
    @market.name = "hah"
    assert @market.valid?
    @market.name = "NASDAQNASDAQNASDAQNASDAQNASDAQNASDAQNASDAQNASDAQNAS"
    assert !@market.valid?
  end
  
  def test_market_name_presence
    @market.name = nil
    assert !@market.valid?
  end
end
