require 'test_helper'

class TradeTest < ActiveSupport::TestCase
  fixtures :trades, :positions
  
 def setup
   long_buys_long = :long_lover_buys_long_from_short_lover
   short_sells_short = :short_lover_sells_short_to_long_lover
   
   @trade = Trade.new(:quantity => trades(:normal_trade).quantity,
                      :trade_order_id => trades(:normal_trade).trade_order_id,
                      :counterpart_id => trades(:normal_trade).counterpart_id,
                      :price => trades(:normal_trade).price,
                      :time => trades(:normal_trade).time)
   @long_buys_long_trade = Trade.new(:quantity => trades(long_buys_long).quantity, 
                                     :trade_order_id => trades(long_buys_long).trade_order_id, 
                                     :counterpart_id => trades(long_buys_long).counterpart_id, 
                                     :price => trades(long_buys_long).price, 
                                     :time => trades(long_buys_long).time)                    
   @short_sells_short_trade = Trade.new(:quantity => trades(short_sells_short).quantity, 
                                        :trade_order_id => trades(short_sells_short).trade_order_id, 
                                        :counterpart_id => trades(short_sells_short).counterpart_id, 
                                        :price => trades(short_sells_short).price, 
                                        :time => trades(short_sells_short).time)
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
   boost_unfilled_quantity @long_buys_long_trade
   @long_buys_long_trade.trade_order.save!
   @long_buys_long_trade.execute
   @long_position = Position.find(:first, 
                              :conditions => {:stock_id => @long_buys_long_trade.trade_order.stock_id,
                                              :portfolio_id => @long_buys_long_trade.trade_order.portfolio_id,
                                              :is_long => @long_buys_long_trade.trade_order.is_long})
   assert_not_nil @long_position
   assert_equal @long_position.quantity, 200
   assert_equal 0, @long_buys_long_trade.trade_order.unfilled_quantity
 end
 
 def test_execute_trade_updates_position
   @short_position = Position.find(:first, 
                                   :conditions => {:stock_id => @short_sells_short_trade.trade_order.stock_id,
                                                   :portfolio_id => @short_sells_short_trade.trade_order.portfolio_id,
                                                    :is_long => @short_sells_short_trade.trade_order.is_long})
                                                
   assert_not_nil @short_position
   boost_unfilled_quantity @short_sells_short_trade
   @short_sells_short_trade.trade_order.save!
   @short_sells_short_trade.execute
   @short_position = Position.find(:first, 
                                   :conditions => {:stock_id => @short_sells_short_trade.trade_order.stock_id,
                                                   :portfolio_id => @short_sells_short_trade.trade_order.portfolio_id,
                                                   :is_long => @short_sells_short_trade.trade_order.is_long})
                                                
   assert_not_nil @short_position
   assert_equal @short_position.quantity, 300
   assert_equal 0, @short_sells_short_trade.trade_order.unfilled_quantity
 end
 
 def test_cash_flow
   boost_unfilled_quantity @long_buys_long_trade 
   @long_buys_long_trade.execute
   portfolio = @long_buys_long_trade.trade_order.portfolio
   assert_equal 236466, portfolio.cash
   boost_unfilled_quantity @short_sells_short_trade
   @short_sells_short_trade.execute
   portfolio = @short_sells_short_trade.trade_order.portfolio
   assert_equal 254905, portfolio.cash
 end
 
end
