require 'test_helper'

class TradeTest < ActiveSupport::TestCase
  fixtures :devices, :imobile_push_notifications, :positions, :trades
  
  def setup
    normal_trade = trades :normal_trade
    @trade = Trade.new :quantity => normal_trade.quantity,
                       :trade_order_id => normal_trade.trade_order_id,
                       :counterpart_id => normal_trade.counterpart_id,
                       :price => normal_trade.price,
                       :time => normal_trade.time
 
    @lbl_trade = trades :long_lover_buys_long_from_short_lover
    @sss_trade = trades :short_lover_sells_short_to_long_lover
  end
 
  def test_setup_valid
    assert @trade.valid?
  end
 
  def test_quantity_presence
    @trade.quantity = nil
    assert !@trade.valid?
  end
 
  def test_trade_order_id_presence
    @trade.trade_order_id = nil
    assert !@trade.valid?
  end
 
  def test_trade_order_id_must_be_greater_than_zero
    @trade.trade_order_id = -1
    assert !@trade.valid?
  end
 
  def test_counterpart_id_nil_ok
    @trade.counterpart_id = nil
    assert @trade.valid?
  end
 
  def test_price_presence
    @trade.price = nil 
    assert !@trade.valid?
  end
 
  def test_price_scale
    @trade.price = 9.999
    assert !@trade.valid?
  end
 
  def test_price_precision
    @trade.price = TradeOrder::MAX_PRICE_PER_SHARE  + 0.01
    assert !@trade.valid?
  end
 
  def test_price_not_negative
    @trade.price = -9.90
    assert !@trade.valid?
  end
 
  def test_price_not_zero
    @trade.price = 0
    assert !@trade.valid?
  end
 
  def test_price_format
    @trade.price = 'blah'
    assert !@trade.valid?
  end
 
  def test_quantity_presence 
    @trade.quantity = nil
    assert !@trade.valid?
  end
 
  def test_quantity_format
    @trade.quantity = 10.2
    assert !@trade.valid?
    @trade.quantity = 'blah'
    assert !@trade.valid?
  end
 
  def test_quantity_upper_bound
    @trade.quantity = TradeOrder::MAX_QUANTITY_SHARES_PER_TRADE + 1
    assert !@trade.valid?
  end
 
  def test_trade_quantity_non_negative
    @trade.quantity = -9
    assert !@trade.valid?
  end
 
  def test_trade_quantity_not_zero
    @trade.quantity = 0
    assert !@trade.valid?
  end
 
  def test_time_presence
    @trade.time = nil
    assert !@trade.valid?
  end
 
  def test_time_format
    @trade.time = 'blahblah'
    assert !@trade.valid?
  end
 
  # Boosts a trade order's unfilled shares, so a trade can execute.
  # This is a hack we're using so we can use fixtures that have unfilled_quantity
  # set to 0. Changing the fixtures would break other tests. One day...
  def boost_unfilled_quantity(trade)
    trade.trade_order.unfilled_quantity = trade.quantity
  end
 
  def test_execute_trade_creates_position
    boost_unfilled_quantity @lbl_trade
    @lbl_trade.trade_order.save!
    @lbl_trade.execute
    long_position = @lbl_trade.trade_order.target_position
   
    assert_equal 200, long_position.quantity,
                 'Trade execution did not set correct position quantity'
    assert_equal 0, @lbl_trade.trade_order.unfilled_quantity
                 'Trade execution did not fill the corresponding order'
  end
 
  def test_execute_trade_updates_position
    short_position = @sss_trade.trade_order.target_position
    assert !short_position.new_record?,
           'Trade does not have associated position'
   
    boost_unfilled_quantity @sss_trade
    @sss_trade.trade_order.save!
    @sss_trade.execute
    short_position = @sss_trade.trade_order.target_position

    assert_equal 300, short_position.quantity,
                 'Trade execution did not set correct position quantity'
  end
  
  def test_execute_trade_sends_notification
    boost_unfilled_quantity @trade
    # The trade gets broken into 2 because of overflow.
    assert_difference 'ImobilePushNotification.count', 2 do
      @trade.execute
    end
  end
 
  def test_execute_trade_handles_overflow
    trade = trades(:normal_trade)
    order = trade.trade_order
    position = order.target_position
    assert !position.new_record?, 'Trade does not have associated position'
   
    # Hack up trade and trade order to generate overflow
    order.quantity = trade.quantity = position.quantity + 100
    order.save!
    
    old_trade_orders_count = TradeOrder.count
    old_trades_count = Trade.count
    expected_cash = order.portfolio.cash - trade.price * trade.quantity
    expected_unfilled = order.unfilled_quantity - trade.quantity
    trade.execute
    assert !Position.find_by_id(position.id),
           'Overflown position was not deleted'
    assert_equal old_trade_orders_count + 1, TradeOrder.count,
                 'Adjusting trade order was not generated on overflowing trade'
    assert_equal old_trades_count + 1, Trade.count,
                 'Adjusting trade was not generated on overflowing trade'
    assert_equal expected_cash, order.portfolio.reload.cash,
                 'Porfolio cash was not updated correctly'
    assert_equal expected_unfilled, order.unfilled_quantity,
                 'Adjusted trade order left unfilled'
    
    last_trade = Trade.all.last
    assert_equal 100, last_trade.quantity, 'Adjusting trade has bad quantity'
    assert_equal trade.price, last_trade.price, 'Adjusting trade has bad price'
    assert_equal order.stock_id, last_trade.trade_order.stock_id,
                 'Adjusting trade order does not point to the right stock'
    assert_equal order.portfolio_id, last_trade.trade_order.portfolio_id,
                 'Adjusting trade order does not point to the right portfolio'
    assert_equal 0, last_trade.trade_order.unfilled_quantity,
                 'Adjusting trade order was not saved as filled'
  end
  
  def test_execute_trade_handles_absent_position
    trade = trades(:normal_trade)
    order = trade.trade_order
    position = order.target_position
    assert !position.new_record?, 'Trade does not have associated position'
    
    # Hack accounting for the test.
    position.destroy
    order.quantity = order.unfilled_quantity = trade.quantity
    order.save!
    
    expected_cash = order.portfolio.cash - trade.price * trade.quantity 
    trade.execute
    assert_equal expected_cash, order.portfolio.reload.cash,
                 'Porfolio cash was not updated correctly'    
  end
 
  def test_execute_trade_updates_portfolio_cash
    boost_unfilled_quantity @lbl_trade 
    @lbl_trade.execute
    portfolio = @lbl_trade.trade_order.portfolio   
    # 200 shares of gs at 67.67 => 250000 - 200 * 67.67 = 23466
    assert_equal 236466, portfolio.cash
   
    boost_unfilled_quantity @sss_trade
    @sss_trade.execute
    portfolio = @sss_trade.trade_order.portfolio
    # 100 shares of gs at 49.05 => 250000 + 100 * 49.05 = 254905
    assert_equal 254905, portfolio.cash
  end
  
  def test_execute_trade_clamps_cash
    boost_unfilled_quantity @sss_trade
    @sss_trade.portfolio.cash = Portfolio::MAX_CASH
    assert_difference('WarningFlag.count', 1,
                      'Trading clamps cash with warning flag') do
      @sss_trade.execute
    end
    portfolio = @sss_trade.trade_order.portfolio
    assert_equal Portfolio::MAX_CASH, portfolio.cash, 'Trading clamps cash'
  end
  
  def test_execution_notification_payload
    boost_unfilled_quantity @trade
    @trade.execute
    payload = @trade.execution_notification_payload
    golden_text =
        'Executed: Short 450 GS @ $67.67/ea. Cash balance: $9,330,067.00'
    assert_equal golden_text, payload[:apn][:alert], "Wrong notification text"
    assert_equal @trade.trade_order.id, payload[:trade_order_id],
                 "Wrong trade order"
  end
  
  def test_send_execution_notification
    boost_unfilled_quantity @trade
    @trade.execute
    notifications = @trade.send_execution_notification
    assert_equal 1, notifications.length, 'Expected 1 notification'
    notification = notifications.first
    
    assert_equal devices(:iphone_3g), notification.device,
                 "The notification should go to rich_kid's device"
    golden_text =
        'Executed: Short 450 GS @ $67.67/ea. Cash balance: $9,330,067.00'
    assert_equal golden_text, notification.payload[:apn][:alert],
                 'The notification reflects the wrong order'
  end
end
