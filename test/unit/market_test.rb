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
end
