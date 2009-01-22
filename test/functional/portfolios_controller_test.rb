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
    assert_equal Set.new([trade_orders(:buy_to_cover_short_with_stop_and_limit_orders), trade_orders(:buy_long_with_stop_order), trade_orders(:buy_short_with_limit_order)]), Set.new(assigns(:trade_orders))
    assert_equal Set.new([trades(:normal_trade), trades(:order_filled_with_market)]), Set.new(assigns(:trades))
    assert_equal Set.new([positions(:ms_long), positions(:ms_short), positions(:gs_long), positions(:gs_short)]), Set.new(assigns(:positions))
  end
end
