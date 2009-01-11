require 'test_helper'

class TradeOrdersControllerTest < ActionController::TestCase
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
end
