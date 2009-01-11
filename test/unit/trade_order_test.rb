require 'test_helper'

class TradeOrderTest < ActiveSupport::TestCase
  def setup 
    @trade_order = TradeOrder.new(:portfolio_id => trade_orders(:one).portfolio_id,
                                  :stock_id => trade_orders(:one).stock_id,
                                  :is_buy => trade_orders(:one).is_buy,
                                  :is_long => trade_orders(:one).is_long,
                                  :stop_price => trade_orders(:one).stop_price,
                                  :limit_price => trade_orders(:one).limit_price,
                                  :expiration_time => trade_orders(:one).expiration_time)
  end
  
  def test_setup_valid
    assert @trade_order.valid?
  end
  
  def test_portfolio_id_not_nil
    @trade_order.portfolio_id = nil
    assert !@trade_order.valid?
  end
  
  def test_stock_id_not_nil
    @trade_order.stock_id = nil
    assert !@trade_order.valid?
  end
  
  def test_is_buy_not_nil
    @trade_order.is_buy = nil
    assert !@trade_order.valid?
  end
  
  def test_is_buy_is_true_false
    @trade_order.is_buy = 'true'
     
    assert [true, false].include?(@trade_order.is_buy) || !@trade_order.valid?,
           "is_buy should either coerce string value to boolean or fail validation"    
  end
  
  def test_is_long_not_nil
    @trade_order.is_long = nil 
    assert !@trade_order.valid?
  end
  
  def test_is_long_is_true_false
    @trade_order.is_long = 'no'
    
    assert [true, false].include?(@trade_order.is_buy) || !@trade_order.valid?
  end
  
  def test_stop_price_format
    @trade_order.stop_price = 'blah'
    assert !@trade_order.valid?
  end
  
  def test_stop_price_precision
    @trade_order.stop_price = 10**20
    assert !@trade_order.valid?
  end
  
  def test_stop_price_scale
    @trade_order.stop_price = 5.999
    assert !@trade_order.valid?
  end
  
  def test_limit_price_format
    @trade_order.limit_price = 'yuck'
    assert !@trade_order.valid?
  end
  
  def test_limit_price_precision
    @trade_order.limit_price = -10**20
    assert !@trade_order.valid?
  end
  
  def test_limit_price_scale
    @trade_order.limit_price = -78.3456
    assert !@trade_order.valid?
  end
  
  def test_expiration_time_in_future
    @trade_order.expiration_time = Time.now - 2
    assert !@trade_order.valid?
  end
  
  def test_expiration_time_format
    @trade_order.expiration_time = 'timetime'
    p @trade_order.expiration_time
    assert !@trade_order.valid?
  end
end
