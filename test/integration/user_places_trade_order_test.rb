require 'test_helper'

class UserPlacesTradeOrderTest < ActionController::IntegrationTest
  fixtures :all

  # User decides to create account and portfolio on the website. 
  # User creates a new user name and password in the login box.  
  # User logs in.
  # User views his portfolio and decides to place an order.
  # User creates and places a new order.
  # The trade order is added to the trade order table.  
  # User is redirected to his portfolio and sees the new order in a list of trade orders.
  # User finally logs out.
  test "user places trade order" do
    get "/"
    get "/users/new"
    assert_response :success
    
    post_via_redirect "/users", :user => {:name => "bunny", :password => "carrot", :password_confirmation => "carrot"}   
    @user = User.find(:first, :conditions => {:name => "bunny"})
    assert_response :success
    assert_equal "User #{@user.name} was successfully created.", flash[:notice]
    
    assert_not_nil User.find(:first, :conditions => {:name => "bunny"})
    @portfolio = Portfolio.find(:first, :conditions => {:user_id => @user.id})
    assert_not_nil @portfolio
    
    post_via_redirect "/admin/login", :name => @user.name, :password => "carrot"
    assert_response :success
    assert_equal @user.id, session[:user_id]
    
    assert_equal 0, TradeOrder.find(:all, :conditions => {:portfolio_id => @user.portfolio.id}).length
    assert_equal 250000.00, @portfolio.cash
    
    get "/trade_orders/new"
    assert_response :success
    
    post "trade_orders/", :trade_order => {:is_limit => false, 
                                                        :ticker => "MS", 
                                                        :quantity => 40, 
                                                        :is_buy => true,
                                                        :is_long => true}
    assert_redirected_to "/portfolios/#{@portfolio.id}"
    assert 1, TradeOrder.find(:all, :conditions => {:portfolio_id => @user.portfolio.id}).length
    
    get "/admin/logout"
    assert_redirected_to "/admin/login"
    assert_equal nil, session[:user_id]
  end
end
