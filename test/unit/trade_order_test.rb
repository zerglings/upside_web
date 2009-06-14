require 'test_helper'

class TradeOrderTest < ActiveSupport::TestCase
  fixtures :stocks, :positions, :trade_orders
  
  def setup 
    order = trade_orders(:buy_to_cover_short_with_stop_and_limit_orders)
    
    @trade_order = TradeOrder.new :portfolio_id => order.portfolio_id,
                                  :stock_id => order.stock_id,
                                  :is_buy => order.is_buy,
                                  :is_long => order.is_long,
                                  :stop_price => order.stop_price,
                                  :limit_price => order.limit_price,
                                  :expiration_time => order.expiration_time,
                                  :quantity => order.quantity
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
    @trade_order.stop_price = (TradeOrder::MAX_PRICE_PER_SHARE + 0.01)
    assert !@trade_order.valid?
  end
  
  def test_stop_price_scale
    @trade_order.stop_price = 5.999
    assert !@trade_order.valid?
  end
  
  def test_stop_price_allows_null
    @trade_order.stop_price = nil
    assert @trade_order.valid?
  end
  
  def test_stop_price_must_be_positive
    @trade_order.stop_price = 0
    assert !@trade_order.valid?
    @trade_order.stop_price = -1.99
    assert !@trade_order.valid?    
  end
  
  def test_limit_price_format
    @trade_order.limit_price = 'yuck'
    assert !@trade_order.valid?
  end
  
  def test_limit_price_precision
    @trade_order.limit_price = -(TradeOrder::MAX_PRICE_PER_SHARE + 0.01)
    assert !@trade_order.valid?
    
  end
  
  def test_limit_price_scale
    @trade_order.limit_price = -78.3456
    assert !@trade_order.valid?
  end
  
  def test_limit_price_allows_null
    @trade_order.limit_price = nil
    assert @trade_order.valid?
  end
  
  def test_limit_price_must_be_positive
    @trade_order.limit_price = 0
    assert !@trade_order.valid?
    @trade_order.limit_price = -1.99
    assert !@trade_order.valid?    
  end  
  
  def test_expiration_time_in_future
    @trade_order.expiration_time = Time.now - 2
    assert !@trade_order.valid?
  end

  def test_expiration_time_format
    @trade_order.expiration_time = 'timetime'
    assert !@trade_order.valid?
  end
  
  def test_quantity_presence
    @trade_order.quantity = nil
    assert !@trade_order.valid?
  end
  
  def test_quantity_is_integer
    @trade_order.quantity = 9.999
    assert !@trade_order.valid?
  end
  
  def test_quantity_non_negative
    @trade_order.quantity = -50
    assert !@trade_order.valid?
  end
  
  def test_quantity_zero_is_invalid
    @trade_order.quantity = 0
    assert !@trade_order.valid?
  end
  
  def test_quantity_less_than_max
    @trade_order.quantity = TradeOrder::MAX_QUANTITY_SHARES_PER_TRADE
    assert !@trade_order.valid?
  end
  
  def test_quantity_sets_unfilled_quantity
    assert_equal @trade_order.unfilled_quantity, @trade_order.quantity
  end
  
  def test_unfilled_quanity_must_be_nonnegative
    @trade_order.unfilled_quantity = -1
    assert !@trade_order.valid?
  end

  def test_unfilled_quanity_can_be_zero
    @trade_order.unfilled_quantity = 0
    assert @trade_order.valid?
  end
  
  def test_unfilled_quanity_cannot_exceed_quantity
    @trade_order.unfilled_quantity = @trade_order.quantity + 1
    assert !@trade_order.valid?
  end
  
  def test_unfilled_quantity_does_not_reset_quantity
    old_quantity = @trade_order.quantity
    @trade_order.unfilled_quantity = 0
    assert_equal old_quantity, @trade_order.quantity
  end
  
  def test_filled
    assert !@trade_order.filled?, "filled? should be false for new orders"
    assert trade_orders(:buy_to_cover_short_with_stop_and_limit_orders).filled?,
           "filled? should be true for filled orders"
  end
  
  def test_client_nonce_accepted
    @trade_order.client_nonce = "1234" * 8
    assert @trade_order.valid?
  end
  
  def test_client_nonce_length
    @trade_order.client_nonce = "1234" * 9
    assert !@trade_order.valid?
  end
  
  def test_client_nonce_uniqueness
    @trade_order.client_nonce = 'rich_nonce'
    assert !@trade_order.valid?, 'No nonce uniqueness check'
    
    @trade_order.client_nonce = 'poor_nonce'
    assert @trade_order.valid?, 'The nonce uniqueness check scope is too broad'
  end

  def test_is_limit_order
    @trade_order.limit_price = nil 
    @trade_order.stop_price  = nil
    assert_equal false, @trade_order.is_limit 
    @trade_order.limit_price = 15.55
    assert_equal true, @trade_order.is_limit
    @trade_order.stop_price = 14.44
    assert_equal true, @trade_order.is_limit
    @trade_order.limit_price = nil
    assert_equal true, @trade_order.is_limit
  end
  
  def test_transaction_type
    @trade_order.is_buy = true
    @trade_order.is_long = true
    assert_equal "Buy", @trade_order.transaction_type
    @trade_order.is_buy = false
    assert_equal "Sell", @trade_order.transaction_type
    @trade_order.is_long = false
    assert_equal "Buy to Cover", @trade_order.transaction_type
    @trade_order.is_buy = true
    assert_equal "Short", @trade_order.transaction_type
  end
  
  def test_ticker_is_set_by_stock_id
    assert_equal stocks(:ms), @trade_order.stock
  end
  
  def test_valid_ticker_sets_stock
    @trade_order.ticker = 'AAPL'
    assert_equal 'AAPL', @trade_order.stock.ticker
  end
  
  def test_invalid_ticker_resets_stock
    @trade_order.ticker = 'QWERTY'
    assert_equal nil, @trade_order.stock
    assert_equal 'QWERTY', @trade_order.ticker
  end
  
  def test_target_position
    assert_equal positions(:ms_short),
                 trade_orders(:buy_to_cover_short_with_stop_and_limit_orders).
                     target_position
                     
    assert_equal positions(:ms_long),
                 trade_orders(:buy_long_with_stop_order).target_position
  end
end
