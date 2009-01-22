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
end
