require 'test_helper'

class TradeOrdersControllerTest < ActionController::TestCase
  test "new order should expire 30 days from now" do
    get :new
    trade_order = @controller.instance_variable_get :@trade_order
    assert_in_delta Time.now + 30.days, trade_order.expiration_time, 5.seconds,
                    "Default expiration time on new order should be 30 days from now."
  end
  
#TODO(celia): test these later!  
  
=begin 
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trade_orders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trade_order" do
    assert_difference('TradeOrder.count') do
      post :create, :trade_order => { }
    end

    assert_redirected_to trade_order_path(assigns(:trade_order))
  end

  test "should show trade_order" do
    get :show, :id => trade_orders(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => trade_orders(:one).id
    assert_response :success
  end

  test "should update trade_order" do
    put :update, :id => trade_orders(:one).id, :trade_order => { }
    assert_redirected_to trade_order_path(assigns(:trade_order))
  end

  test "should destroy trade_order" do
    assert_difference('TradeOrder.count', -1) do
      delete :destroy, :id => trade_orders(:one).id
    end

    assert_redirected_to trade_orders_path
  end
=end
end
