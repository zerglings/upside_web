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
      attr_reader :flushed
            
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
                            with(notifications, 5).
                            and_return { |n, t| n.each(&:destroy) }
    end
    @controller.round 2, 5
  end
  
  def test_push_notifications_buckets_correctly
    prod = imobile_push_notifications(:notify_victors_prod_phone)
    dev = imobile_push_notifications(:notify_victors_ipod)
    bounce = imobile_push_notifications(:bounced)
    notifications = [prod, dev, prod, bounce, prod, dev]
    
    flexmock(@controller).should_receive(:push_notifications_atomic).
                          with([prod, prod], :production).once
    flexmock(@controller).should_receive(:push_notifications_atomic).
                          with([dev, dev], :sandbox).once
    flexmock(@controller).should_receive(:push_notifications_atomic).
                          with([prod], :production).once
      
    assert_equal [prod, prod, dev, dev, prod],
                 @controller.push_notifications(notifications, 2),
                 'push_notifications return value'
    assert bounce.frozen?, 'Destination-less notification not destroyed'
  end
  
  def test_push_notifications_atomic_flow
    context = @contexts[:production]
    flexmock(context).should_receive(:flush).once
    @notifications.each do |notification|
      flexmock(@controller).should_receive(:push_notification!).
                            with(notification, context).once.and_return(nil)      
    end
    
    assert_difference('ImobilePushNotification.count',
                      -@notifications.length) do
      @controller.push_notifications_atomic @notifications, :production
    end
  end
  
  def test_push_notifications_atomic_reraises_errors_correctly
    context = @contexts[:production]
    flexmock(@controller).should_receive(:push_notification!).
                          with(@notifications[0], context).times(3).
                          and_return(nil)
    flexmock(@controller).should_receive(:push_notification!).
                          with(@notifications[1], context).times(3).
                          and_raise(StubbedError)
    flexmock(@controller).should_receive(:push_notification!).
                          with(@notifications[2], context).never
    flexmock(@controller).should_receive(:restore_context).
                          with(:production).times(3).and_return(nil)
    flexmock(@contexts[:production]).should_receive(:flush).never
    
    assert_no_difference('ImobilePushNotification.count') do
      assert_raise(StubbedError) do
        @controller.push_notifications_atomic @notifications, :production
      end
    end
  end

  def test_push_notifications_retries_correctly
    context = @contexts[:production]
    context_exception_bit = true
    flexmock(context).should_receive(:flush).times(2).and_return do
      next nil unless context_exception_bit
      context_exception_bit = false
      raise StubbedError
    end
    
    flexmock(@controller).should_receive(:push_notification!).
                          with(@notifications[0], context).times(3).
                          and_return(nil)
    push_exception_bit = true
    flexmock(@controller).should_receive(:push_notification!).
                          with(@notifications[1], context).times(3).
                          and_return do
      next nil unless push_exception_bit
      push_exception_bit = false
      raise StubbedError
    end
    flexmock(@controller).should_receive(:push_notification!).
                          with(@notifications[2], context).times(2).
                          and_return(nil)
    flexmock(@controller).should_receive(:restore_context).
                          with(:production).times(2).and_return(nil)

    assert_difference('ImobilePushNotification.count',
                      -@notifications.length) do
      assert_equal @notifications,
                   @controller.push_notifications_atomic(@notifications,
                                                         :production),
                   'push_notifications_atomic return value'
    end
  end
  
  def test_push_notification
    context = @contexts[:sandbox]
    notification = imobile_push_notifications(:notify_victors_ipod)
    golden_token =
        Imobile.pack_hex_push_token devices(:ipod_touch_2g).app_push_token
    golden_payload = { 'aps' => {'alert' => 'StockPlay functional test'},
                       :push_token =>  golden_token }
    flexmock(context).should_receive(:push).with(golden_payload)
    @controller.push_notification! notification, context
  end
  
  def test_notification_server_type
    assert_equal :production, @controller.notification_server_type(
        imobile_push_notifications(:notify_victors_prod_phone)),
        "Failed to recognize production context"
    assert_equal :sandbox, @controller.notification_server_type(
        imobile_push_notifications(:notify_victors_ipod)),
        "Failed to recognize sandbox context"
    assert_equal nil, @controller.notification_server_type(
                 imobile_push_notifications(:bounced)),
        "Returned context for device without push token"
  end
  
  def test_smoke
    @controller = ImobileEx::NotificationDeliveryController.new
    # Small max_step_size to go through two loop iterations.
    @controller.round 2, 1
  end
end
