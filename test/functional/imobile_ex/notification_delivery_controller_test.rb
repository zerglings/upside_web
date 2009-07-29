require 'test_helper'
require 'flexmock/test_unit'

class NotificationDeliveryControllerTest < ActionController::IntegrationTest
  # This really is a functional test, but the controller it's testing does not
  # inherit from ActionController::Base

  fixtures :devices, :imobile_push_notifications, :portfolios
  
  Controller = ImobileEx::NotificationDeliveryController
  
  # Stubs out the connections to Apple's servers, because the SSL connections
  # are expensive to establish for every test.
  class StubbedDeliveryController < Controller
    class StubbedContext
      def initialize(server_context)
        @server_context = server_context
        @flushed = false
      end
      
      def inspect
        "#{@server_context} mock context"
      end
      
      def flush
        @flushed = true
      end
      
      def close
        raise 'Suspicious: context closed without flushing.' unless @flushed
      end
    end
    def create_apns_context(server_context)
      StubbedContext.new server_context
    end
  end
  
  # Stub exception class helping ensure that push_notifications re-raises the
  # appropriate exceptions. 
  class StubbedError < RuntimeError    
  end
  
  def setup
    super
    @controller = StubbedDeliveryController.new
    # Reaching inside the controller. Bad, except this is its test.
    @contexts = @controller.instance_variable_get :@contexts    
    @notifications = ImobilePushNotification.all(:order => :id)
  end
  
  def test_round_fetches_notifications_correctly
    [@notifications[0, 2], @notifications[2, 1]].each do |notifications|
      flexmock(@controller).should_receive(:push_notifications).
                            with(notifications).
                            and_return { |n| n.each(&:destroy) }
    end
    @controller.round 2
  end
  
  def test_push_notifications_normal_flow
    @notifications.each do |notification|
      flexmock(@controller).should_receive(:push_notification!).
                            with(notification).once.and_return(nil)      
    end
    @controller.push_notifications @notifications    
  end
  
  def test_push_notifications_reraises_errors_correctly
    notifications_count = @notifications.length
    flexmock(@controller).should_receive(:push_notification!).
                          with(@notifications[0]).never
    flexmock(@controller).should_receive(:push_notification!).
                          with(@notifications[1]).twice.and_raise(StubbedError)
    flexmock(@controller).should_receive(:push_notification!).
                          with(@notifications[2]).once.and_return(nil)
    assert_raise(StubbedError) { @controller.push_notifications @notifications }
    
    assert_equal notifications_count, ImobilePushNotification.count,
                 "Undelivered notifications got removed from the database"
  end
  
  def test_push_notification
    notification = imobile_push_notifications(:notify_victors_ipod)
    golden_token =
        Imobile.pack_hex_push_token devices(:ipod_touch_2g).app_push_token
    golden_payload = { 'aps' => {'alert' => 'StockPlay functional test'},
                       :push_token =>  golden_token }
    flexmock(@contexts[:sandbox]).should_receive(:push).with(golden_payload)
    @controller.push_notification! notification
    
    assert_equal @notifications.length - 1, ImobilePushNotification.count,
                 "Pushing a notification didn't remove it from the database"
  end
  
  def test_push_notification_without_token
    notification = imobile_push_notifications(:bounced)
    flexmock(@contexts[:sandbox]).should_receive(:push).never
    @controller.push_notification! notification 

    assert_equal @notifications.length - 1, ImobilePushNotification.count,
                 "Pushing a notification didn't remove it from the database"
  end
  
  def test_push_notification_with_transmission_error
    notification = imobile_push_notifications(:notify_victors_ipod)
    flexmock(@contexts[:sandbox]).should_receive(:push).once.
                                  and_raise(StubbedError)
    assert_raises(StubbedError) { @controller.push_notification! notification }
    assert_equal @notifications.length, ImobilePushNotification.count,
                 "Undelivered notification got removed from the database"
  end
  
  def test_context_for_notification
    contexts = @controller.instance_variable_get :@contexts
    
    assert_equal contexts[:production], @controller.context_for_notification(
        imobile_push_notifications(:notify_victors_prod_phone)),
        "Failed to recognize production context"
    assert_equal contexts[:sandbox], @controller.context_for_notification(
        imobile_push_notifications(:notify_victors_ipod)),
        "Failed to recognize sandbox context"
    assert_equal contexts[:development], @controller.context_for_notification(
        imobile_push_notifications(:bounced)),
        "Returned context for device without push token"
  end
  
  def test_smoke
    @controller = ImobileEx::NotificationDeliveryController.new
    # Small max_step_size to go through two loop iterations.
    @controller.round 2
  end
end
