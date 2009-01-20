require 'test_helper'

class OrderCancellationControllerTest < ActionController::TestCase
  fixtures :order_cancellations, :users, :trade_orders, :portfolios
  
  def setup
    @request.session[:user_id] = users(:rich_kid).id
    @order = trade_orders(:buy_short_with_limit_order)
  end
  
  def test_cancelled_order_is_added_to_order_cancellation_database
    count_before = OrderCancellation.count 
    post :create, :trade_order_id => @order.id
    count_after = OrderCancellation.count
    
    assert_equal 1, count_after - count_before 
    assert_equal 'Trade order was successfully cancelled.', flash[:notice]
    assert_redirected_to portfolios(:rich_kid)
  end
  
  def test_orders_cannot_be_cancelled_more_than_once
    count_before = OrderCancellation.count
    post :create, :trade_order_id => @order.id
    post :create, :trade_order_id => @order.id
    count_after = OrderCancellation.count
    
    assert 1, count_after - count_before
  end
end
