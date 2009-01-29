require 'test_helper'

class TradeOrdersControllerTest < ActionController::TestCase
  fixtures :users, :trade_orders
  
  def setup
    @request.session[:user_id] = users(:rich_kid).id
    @order = trade_orders(:buy_to_cover_short_with_stop_and_limit_orders)
  end
  
  test "new order should expire 30 days from now" do
    get :new
    trade_order = @controller.instance_variable_get :@trade_order
    assert_in_delta Time.now + 30.days, trade_order.expiration_time, 5.seconds,
                    "Default expiration time on new order should be 30 days from now."
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trade_orders)
  end
  
  test "should show trade_order" do
    get :show, :id => @order.id
    assert_response :success
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @order.id
    assert_response :success
  end
  
  test "should create trade_order" do
    count_before = TradeOrder.count
    post :create, :trade_order => {:ticker => @order.stock.ticker,
                                   :is_limit => false,
                                   :quantity => @order.quantity}
    count_after = TradeOrder.count
    
    assert_equal 1, count_after - count_before
    assert_redirected_to portfolios(:rich_kid) 
    assert_equal 'TradeOrder was successfully created.', flash[:notice]
  end
  
  test "should XML-create market order" do
    assert_difference('TradeOrder.count') do
      post :create, :trade_order => {:ticker => "JCG",
                                     :quantity => @order.quantity,
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
      assert_select 'quantity', @order.quantity.to_s
      assert_select 'limit_price', '0'
      assert_select 'model_id'
    end
  end
  
  test "should create trade_order when using a new ticker" do
    assert_difference('TradeOrder.count') do
      post :create, :trade_order => {:ticker => "JCG", :quantity => @order.quantity}
    end
    
    assert_redirected_to portfolios(:rich_kid) 
    assert_equal 'TradeOrder was successfully created.', flash[:notice]
  end
  
  test "should destroy trade_order" do
    assert_difference('TradeOrder.count', -1) do
      delete :destroy, :id => @order.id
    end

    assert_redirected_to portfolios(:rich_kid)
  end
end
