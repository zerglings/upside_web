require 'test_helper'

module CommonTradeControllerTests
  def common_setup
    @request.session[:user_id] = @user.id
    @portfolio = @user.portfolio
    @trade = trades(:normal_trade)
  end
  
  def assert_access_denied
    assert_redirected_to :controller => :welcome, :action => :dashboard
    assert_equal "Admin access only.", flash[:error]
  end
end

class AdminTradeControllerTest < ActionController::TestCase
  include CommonTradeControllerTests
  tests TradesController
  fixtures :trades, :users, :portfolios
  
  def setup
    @user = users(:admin)
    common_setup
  end
  
  test "admin allowed to get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trades)
  end
  
  test "admin allowed to show trade" do
    get :show, :id => @trade.id
    assert_response :success
  end
  
  test "admin allowed to get new" do
    get :new
    assert_response :success
  end
  
  test "admin allowed to create trade" do
    assert_difference('Trade.count') do
      post :create, :trade => {:time => @trade.time, 
                               :quantity => @trade.quantity, 
                               :trade_order_id => @trade.trade_order_id,
                               :price => @trade.price }
    end
    
    assert_redirected_to trade_path(assigns(:trade))
  end
  
  test "admin allowed to update trade" do
    put :update, :id => @trade.id, :trade => {:time => @trade.time, 
                                              :quantity => trades(:order_filled_with_market).quantity, 
                                              :trade_order_id => @trade.trade_order_id,
                                              :price => @trade.price }
    
    assert_equal 'Trade was successfully updated.', flash[:notice]
    assert_equal trades(:order_filled_with_market).quantity, @trade.reload.quantity 
    assert_redirected_to trade_path(assigns(:trade))
  end
  
  test "admin allowed to destroy trade" do
    assert_difference('Trade.count', -1) do
      delete :destroy, :id => trades(:normal_trade).id
    end

    assert_redirected_to trades_path
  end
end

class TradesControllerTest < ActionController::TestCase
  include CommonTradeControllerTests
  fixtures :trades, :users, :portfolios

  def setup
    @user = users(:rich_kid)
    common_setup
  end
  
  test "user not allowed to view index of trades" do
    get :index
    assert_access_denied
  end
   
  test "user not allwed to view trades" do
    get :show, :id => @trade.id
    assert_access_denied
  end

  test "user not allowed to get new" do
    get :new
    assert_access_denied
  end
  
  test "user not allowed to create trade" do
    count_before = Trade.count
    post :create, :trade => {:time => @trade.time, 
                               :quantity => @trade.quantity, 
                               :trade_order_id => @trade.trade_order_id,
                               :price => @trade.price }
    count_after = Trade.count
    assert_equal count_after, count_before
    assert_access_denied
  end

  test "user not allowed to update trade" do
    put :update, :id => @trade.id, :trade => {:time => @trade.time, 
                                              :quantity => @trade.quantity, 
                                              :trade_order_id => @trade.trade_order_id,
                                              :price => @trade.price }
    
    assert_access_denied
  end
  
  test "user not allowed to destroy trade" do
    assert_difference('Trade.count', 0) do
      delete :destroy, :id => trades(:normal_trade).id
    end

    assert_access_denied
  end
end