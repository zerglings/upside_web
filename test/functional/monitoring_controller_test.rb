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
    assert_equal WarningFlag.count, stats['warnings']
    assert_equal ImobilePushNotification.count, stats['push_notifications']
    assert_in_delta Time.now.to_f,
        DateTime.strptime(stats['created_at'], '%H:%M:%S %d-%b-%Y %Z').to_f, 2.0
  end
end
