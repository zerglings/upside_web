require 'test_helper'

class TradeTest < ActiveSupport::TestCase
 def setup
   @trade = Trade.new(:quantity => trades(:one).quantity,
                      :trade_order_id => trades(:one).trade_order_id,
                      :counterpart_id => trades(:one).counterpart_id,
                      :price => trades(:one).price,
                      :time => trades(:one).time)
 end
 
 def test_setup_valid
   assert @trade.valid?
 end
 
 def test_trade_order_id_presence
   @trade.trade_order_id = nil
   assert !@trade.valid?
 end
 
 def test_counterpart_id_presence
   @trade.counterpart_id = nil
   assert !@trade.valid?
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
   @trade.price = Trade::MAX_PRICE + 0.01
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
 
 def test_quantity_precision
   @trade.quantity = Trade::MAX_SHARES + 1
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
