require 'test_helper'

module CommonCancellationControllerTests
  def common_setup
    @portfolio = @user.portfolio
    @order = trade_orders(:buy_short_with_limit_order)
  end
  
  def test_cancelled_order_is_added_to_order_cancellation_database
    count_before = OrderCancellation.count 
    post :create, :trade_order_id => @order.id
    count_after = OrderCancellation.count
    
    assert_equal 1, count_after - count_before 
    assert_equal 'Trade order was successfully cancelled.', flash[:notice]
    assert_redirected_to @portfolio
  end
  
  def test_orders_cannot_be_cancelled_more_than_once
    count_before = OrderCancellation.count
    post :create, :trade_order_id => @order.id
    post :create, :trade_order_id => @order.id
    count_after = OrderCancellation.count
    
    assert 1, count_after - count_before
  end
end

class OrderCancellationControllerTest < ActionController::TestCase
  include CommonCancellationControllerTests
  fixtures :order_cancellations, :users, :trade_orders, :portfolios
  
  def setup
    @user = users(:rich_kid)
    @request.session[:user_id] = @user.id
    common_setup
  end
  
  test "users cannot cancel trade orders of other users" do
    count_before = OrderCancellation.count 
    post :create, :trade_order_id => trade_orders(:sell_long_without_stop_or_limit_orders).id
    count_after = OrderCancellation.count
    assert_equal count_before, count_after
    assert_redirected_to :controller => :welcome, :action => :dashboard
  end
end

class AdminOrderCancellationControllerTest < ActionController::TestCase
  include CommonCancellationControllerTests
  fixtures :order_cancellations, :users, :trade_orders, :portfolios
  tests OrderCancellationController
  
  def setup
    @user = users(:admin)
    @request.session[:user_id] = @user.id
    common_setup
  end
end
