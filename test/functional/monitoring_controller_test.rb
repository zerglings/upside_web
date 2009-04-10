require 'test_helper'

class MonitoringControllerTest < ActionController::TestCase
  def test_gadget_stats
    get :gadget, :callback => 'callbackProc'
    
    json_match = /^callbackProc\((.*)\)$/.match @response.body
    assert json_match, "Response not in JSONP format: #{@response.body}"
    
    stats = JSON.parse json_match[1]
    assert_equal Device.count, stats['devices']
    assert_equal TradeOrder.count, stats['orders']
    assert_equal Trade.count, stats['trades']
    assert_equal User.count, stats['users']
  end
end
