require 'test_helper'

class TradeTest < ActiveSupport::TestCase
 def setup
   @trade = Trade.new(:quantity => trades(:normal_trade).quantity,
                      :trade_order_id => trades(:normal_trade).trade_order_id,
                      :counterpart_id => trades(:normal_trade).counterpart_id,
                      :price => trades(:normal_trade).price,
                      :time => trades(:normal_trade).time)
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
end
