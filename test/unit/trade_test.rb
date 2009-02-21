require 'test_helper'

class TradeTest < ActiveSupport::TestCase
  fixtures :trades, :positions
  
 def setup
   normal_trade = trades(:normal_trade)
   long_buys_long = trades(:long_lover_buys_long_from_short_lover)
   short_sells_short = trades(:short_lover_sells_short_to_long_lover)
   
   @trade = Trade.new(:quantity => normal_trade.quantity,
                      :trade_order_id => normal_trade.trade_order_id,
                      :counterpart_id => normal_trade.counterpart_id,
                      :price => normal_trade.price,
                      :time => normal_trade.time)
   @lbl_trade = Trade.new(:quantity => long_buys_long.quantity, 
                                     :trade_order_id => long_buys_long.trade_order_id, 
                                     :counterpart_id => long_buys_long.counterpart_id, 
                                     :price => long_buys_long.price, 
                                     :time => long_buys_long.time)                    
   @sss_trade = Trade.new(:quantity => short_sells_short.quantity, 
                                        :trade_order_id => short_sells_short.trade_order_id, 
                                        :counterpart_id => short_sells_short.counterpart_id, 
                                        :price => short_sells_short.price, 
                                        :time => short_sells_short.time)
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
 
 def test_create_trade_also_creates_position_if_position_is_initially_nonexistent
   @lbl_trade.execute
   @long_position = Position.find(:first, 
                              :conditions => {:stock_id => @lbl_trade.trade_order.stock_id,
                                              :portfolio_id => @lbl_trade.trade_order.portfolio_id,
                                              :is_long => @lbl_trade.trade_order.is_long})
   assert_not_nil @long_position
   assert_equal 200, @long_position.quantity
 end
 
 def test_create_trade_also_updates_position_if_position_is_initially_existent
   @short_position = Position.find(:first, 
                                   :conditions => {:stock_id => @sss_trade.trade_order.stock_id,
                                                   :portfolio_id => @sss_trade.trade_order.portfolio_id,
                                                    :is_long => @sss_trade.trade_order.is_long})
                                                
   assert_not_nil @short_position
   @sss_trade.execute
   @short_position = Position.find(:first, 
                                   :conditions => {:stock_id => @sss_trade.trade_order.stock_id,
                                                   :portfolio_id => @sss_trade.trade_order.portfolio_id,
                                                   :is_long => @sss_trade.trade_order.is_long})
                                                
   assert_not_nil @short_position
   assert_equal 300, @short_position.quantity
 end
 
 def test_cash_flow
   @lbl_trade.execute
   portfolio = @lbl_trade.trade_order.portfolio
   # 200 shares of gs at 67.67 => 250000 - 200 * 67.67 = 23466
   assert_equal 236466, portfolio.cash
   @sss_trade.execute
   portfolio = @sss_trade.trade_order.portfolio
   # 100 shares of gs at 49.05 => 250000 + 100 * 49.05 = 254905
   assert_equal 254905, portfolio.cash
 end
 
end
