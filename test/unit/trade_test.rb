require 'test_helper'

class TradeTest < ActiveSupport::TestCase
  fixtures :trades, :positions
  
 def setup
   @trade = Trade.new(:quantity => trades(:normal_trade).quantity,
                      :trade_order_id => trades(:normal_trade).trade_order_id,
                      :counterpart_id => trades(:normal_trade).counterpart_id,
                      :price => trades(:normal_trade).price,
                      :time => trades(:normal_trade).time)
   @trade1 = Trade.new(:quantity => trades(:user_B_buys_long_from_user_A).quantity,
                      :trade_order_id => trades(:user_B_buys_long_from_user_A).trade_order_id,
                      :counterpart_id => trades(:user_B_buys_long_from_user_A).counterpart_id,
                      :price => trades(:user_B_buys_long_from_user_A).price,
                      :time => trades(:user_B_buys_long_from_user_A).time)                    
   @trade2 = Trade.new(:quantity => trades(:user_B_sells_short_to_user_A).quantity,
                      :trade_order_id => trades(:user_B_sells_short_to_user_A).trade_order_id,
                      :counterpart_id => trades(:user_B_sells_short_to_user_A).counterpart_id,
                      :price => trades(:user_B_sells_short_to_user_A).price,
                      :time => trades(:user_B_sells_short_to_user_A).time)
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
   setup
   @trade1.save!
   @position1 = Position.find(:first, 
                                :conditions => {:stock_id => @trade1.trade_order.stock_id,
                                                :portfolio_id => @trade1.trade_order.portfolio_id,
                                                :is_long => @trade1.trade_order.is_long})
    print "stock_id"
    p @trade1.trade_order.stock_id
    print "portfolio_id"
    p @trade1.trade_order.portfolio_id
    print "is_long"
    p @trade1.trade_order.is_long
   assert_not_nil @position1
   assert_equal @position1, 300
 end
 
 def test_create_trade_also_updates_position_if_position_is_initially_existent
   setup
   @trade2.save!
   @position2 = Position.find(:first, 
                                :conditions => {:stock_id => @trade2.trade_order.stock_id,
                                                :portfolio_id => @trade2.trade_order.portfolio_id,
                                                :is_long => @trade2.trade_order.is_long})
   assert_not_nil @position2
   assert_equal @position2, 700
 end
 
end
