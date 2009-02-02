require 'test_helper'

module CommonTradeOrderTests
  def common_setup
    @request.session[:user_id] = @user.id
  end
  
  def test_new_order_should_expire_30_days_from_now
    get :new
    trade_order = @controller.instance_variable_get :@trade_order
    assert_in_delta Time.now + 30.days, trade_order.expiration_time, 5.seconds,
                    "Default expiration time on new order should be 30 days from now."
  end
  
  def test_should_show_trade_order
    get :show, :id => @trade_order.id
    assert_response :success
  end
  
  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_trade_order
    count_before = TradeOrder.count
    post :create, :trade_order => {:ticker => @trade_order.stock.ticker,
                                   :is_limit => false,
                                   :quantity => @trade_order.quantity}
    count_after = TradeOrder.count
    
    assert_equal 1, count_after - count_before
    assert_redirected_to @user.portfolio 
    assert_equal 'TradeOrder was successfully created.', flash[:notice]
  end
  
  def test_should_XML_create_market_order
    assert_difference('TradeOrder.count') do
      post :create, :trade_order => {:ticker => "JCG",
                                     :quantity => @trade_order.quantity,
                                     :is_buy => true,
                                     :is_long => true,
                                     :is_limit => false,
                                     :limit_price => 0,
                                     :model_id => 0,
                                     :quantity_unfilled => 0},
                    :format => 'xml'
    end
    assert_response :success
    assert_select 'trade_order' do
      assert_select 'ticker', 'JCG'
      assert_select 'quantity', @trade_order.quantity.to_s
      assert_select 'limit_price', '0'
      assert_select 'model_id'
    end
  end
  
  def test_should_create_trade_order_when_using_new_ticker
    assert_difference('TradeOrder.count') do
      post :create, :trade_order => {:ticker => "JCG", :quantity => @trade_order.quantity}
    end
    
    assert_redirected_to @user.portfolio 
    assert_equal 'TradeOrder was successfully created.', flash[:notice]
  end
end

class AdminTradeOrdersControllerTest < ActionController::TestCase
  include CommonTradeOrderTests
  fixtures :users, :trade_orders, :portfolios  
  tests TradeOrdersController
  
  def setup
    @user = users(:admin)
    common_setup
    @trade_order = trade_orders(:sell_long_without_stop_or_limit_orders)
  end
  
  test "admin can see index of trade orders" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trade_orders)
  end
  
  test "admin can edit trade order " do
    get :edit, :id => trade_orders(:buy_long_with_stop_order).id  
    assert_response :success
  end
  
  test "admin allowed to destroy trade order" do
    count_before = TradeOrder.count
    delete :destroy, :id => @trade_order.id
    count_after = TradeOrder.count
    assert_equal 1, count_before - count_after
    assert_redirected_to @user.portfolio
  end
end

class TradeOrdersControllerTest < ActionController::TestCase
  include CommonTradeOrderTests
  fixtures :users, :trade_orders, :portfolios
  
  def setup
    @user = users(:rich_kid)
    common_setup
    @trade_order = trade_orders(:buy_to_cover_short_with_stop_and_limit_orders)
  end
  
  test "user should not see index of trade orders" do
    get :index
    assert_redirected_to @user.portfolio
  end
  
  test "user should not be able to edit trade orders" do
    get :edit, :id => trade_orders(:buy_long_with_stop_order).id
    assert_redirected_to @user.portfolio
  end
  
  test "user should not be albe to destroy trade orders" do
    assert_difference('TradeOrder.count', 0) do
      delete :destroy, :id => @trade_order.id
    end

    assert_redirected_to @user.portfolio
  end
end
