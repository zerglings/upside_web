require 'test_helper'

class PortfoliosControllerTest < ActionController::TestCase
  fixtures :portfolios, :positions, :trade_orders, :trades, :users
  
  def setup
    @request.session[:user_id] = users(:rich_kid).id
    @portfolio = portfolios(:rich_kid)
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:portfolios)
  end
  
  test "should show portfolio" do
    get :show, :id => @portfolio.id
    assert_response :success
    assert_equal Set.new([:buy_to_cover_short_with_stop_and_limit_orders, 
                          :buy_long_with_stop_order, 
                          :buy_short_with_limit_order].map { |x| trade_orders(x) }),
                 Set.new(assigns(:trade_orders))
    assert_equal Set.new([:normal_trade, :order_filled_with_market].map { |x| trades(x) }), 
                 Set.new(assigns(:trades))
    assert_equal Set.new([:ms_long, :ms_short, :gs_long, :gs_short].map { |x| positions(x) }), 
                 Set.new(assigns(:positions))
  end
  
  test "xml sync" do
    get :sync, :id => 0, :format => 'xml'
    assert_response :success
    
    @portfolio.positions.each do |position|
      assert_select('position') do
        assert_select 'modelId', position.id.to_s
        assert_select 'ticker', position.stock.ticker
        assert_select 'quantity', position.quantity.to_s
        assert_select 'isLong', position.is_long.to_s
      end
    end
    
    @portfolio.trade_orders.each do |trade_order|
      assert_select('trade_order') do
        assert_select 'modelId', trade_order.id.to_s
        assert_select 'ticker', trade_order.stock.ticker
        assert_select 'quantity', trade_order.quantity.to_s
        assert_select 'isBuy', trade_order.is_buy.to_s
        assert_select 'isLong', trade_order.is_long.to_s
        assert_select 'expirationTime', trade_order.expiration_time.to_s        
      end
    end
    
    @portfolio.trades.each do |trade|
      assert_select('trade') do
        assert_select 'modelId', trade.id.to_s
        assert_select 'quantity', trade.quantity.to_s
        assert_select 'price', trade.price.to_s
      end
    end
  end
  
  test "xml sync rejects unauthenticated sessions" do
    @request.session[:user_id] = nil
    get :sync, :id => 0, :format => 'xml'
    assert_response :success
    
    assert_select 'error' do
      assert_select 'reason', 'login'
    end
  end
end
