require 'test_helper'

module CommonPortfolioTests
  def common_setup
    @request.session[:user_id] = @user.id
    @portfolio = portfolios(:rich_kid)    
  end
  
  def test_should_show_portfolio
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
  
  def test_xml_sync
    portfolio_id = @user.is_admin? ? portfolios(:rich_kid).id : 0
    get :sync, :id => portfolio_id, :format => 'xml'
    assert_response :success
    
    assert_select 'portfolio' do
      assert_select 'cash', @portfolio.cash.to_s
    end
    
    
    @portfolio.positions.each do |position|
      assert_select('position') do
        assert_select 'model_id', position.id.to_s
        assert_select 'ticker', position.stock.ticker
        assert_select 'quantity', position.quantity.to_s
        assert_select 'is_long', position.is_long.to_s
      end
    end
    
    @portfolio.trade_orders.each do |trade_order|
      assert_select('trade_order') do
        assert_select 'model_id', trade_order.id.to_s
        assert_select 'ticker', trade_order.stock.ticker
        assert_select 'quantity', trade_order.quantity.to_s
        assert_select 'is_buy', trade_order.is_buy.to_s
        assert_select 'is_long', trade_order.is_long.to_s
        if trade_order.is_limit
          assert_select 'limit_price', trade_order.limit_price.to_s
        else
          assert_select 'limit_price', '0'
        end
        assert_select 'expiration_time', trade_order.expiration_time.to_s        
      end
    end
    
    @portfolio.trades.each do |trade|
      assert_select('trade') do
        assert_select 'model_id', trade.id.to_s
        assert_select 'quantity', trade.quantity.to_s
        assert_select 'price', trade.price.to_s
      end
    end
  end  
end

class AdminPortfoliosControllerTest < ActionController::TestCase
  fixtures :portfolios, :positions, :trade_orders, :trades, :users
  include CommonPortfolioTests
  tests PortfoliosController
  
  def setup
    @user = users(:admin)
    common_setup
  end
  
  test "admin can see index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:portfolios)
  end
  
  test "admin can edit portfolios" do
    get :edit, :id => portfolios(:site_user).id
    assert_response :success
  end
  
  test "admin can update other users' portfolios" do
    put :update, :id => portfolios(:site_user).id
    assert_redirected_to portfolios(:site_user)
  end
end

class PortfoliosControllerTest < ActionController::TestCase
  fixtures :portfolios, :positions, :trade_orders, :trades, :users
  include CommonPortfolioTests
  
  def setup
    @user = users(:rich_kid)
    common_setup
  end
  
  test "user should not see index" do
    @request.session[:user_id] = users(:rich_kid).id  
    get :index
    assert_redirected_to @portfolio
  end
  
  test "users cannot see the portfolio of another user" do
    get :show, :id => portfolios(:site_user).id
    assert_redirected_to @portfolio
  end
  
  test "user cannot edit his/her own portfolio" do
    get :edit, :id => @portfolio.id
    assert_redirected_to @portfolio
  end
  
  test "users cannot update his/her own portfolio" do
    put :update, :id => @portfolio.id
    assert_redirected_to @portfolio
  end
  
  def test_xml_sync_rejects_unquthenticated_sessions
    @request.session[:user_id] = nil
    get :sync, :id => 0, :format => 'xml'
    assert_response :success
    
    assert_select 'error' do
      assert_select 'reason', 'login'
    end
  end  
end
