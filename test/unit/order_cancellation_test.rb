require 'test_helper'

class CancelledOrderTest < ActiveSupport::TestCase
  
  def setup
    @cancel = OrderCancellation.new :trade_order_id => order_cancellations(:order_cancel_one).id
  end
  
  def test_setup_valid
    assert @cancel.valid?
  end
  
  def test_trade_order_id_presence
    @cancel.trade_order_id = nil
    assert !@cancel.valid?
  end
  
  def test_trade_order_id_numericality
    @cancel.trade_order_id = "blah"
    assert !@cancel.valid?
  end
end
