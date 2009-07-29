require 'test_helper'

class ImobilePushNotificationTest < ActiveSupport::TestCase
  fixtures :devices, :imobile_push_notifications, :portfolios

  def setup
    super
    payload = {'aps' => {'alert' => 'Your subscription is about to expire.'}}
    @notification = ImobilePushNotification.new :device => devices(:iphone_3g),
         :payload => payload, :subject => portfolios(:rich_kid)
  end
  
  def test_valid_setup
    assert @notification.valid?
  end

  def test_payload_presence
    @notification.payload = nil
    assert !@notification.valid?
  end

  def test_payload_must_be_hash
    @notification.payload = "Text payload"
    assert_raise ActiveRecord::SerializationTypeMismatch do
      @notification.save!
    end
  end
  
  def test_device_presence
    @notification.device = nil
    assert !@notification.valid?
  end
  
  def test_subject_presence
    @notification.subject = nil
    assert !@notification.valid?
  end
  
  def test_subject_deserialization
    assert_equal({'aps' => {'alert' => 'StockPlay functional test'}},
                 imobile_push_notifications(:notify_victors_ipod).payload)                  
  end
end
