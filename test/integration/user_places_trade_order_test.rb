require 'test_helper'

class UserPlacesTradeOrderTest < ActionController::IntegrationTest
  fixtures :all

=begin
User decides to create a new account on the website.
An associated portfolio is automatically created.
  
User enters a user name and password in the sign up form and clicks create.
User logs in.
User views his portfolio and decides to place an order.
User creates and places a new order.
The trade order is added to the trade order table.  
User is redirected to his portfolio and sees the new order in a list of trade
orders.
User finally logs out.
=end
  test "user places trade order" do
    get "/users/new"
    assert_response :success
    
    user_name = "bunny"
    password = "carrot"
    post_via_redirect "/users", :user => {:name => user_name,
                                          :password => password,
                                          :password_confirmation => password}   
    @user = User.find_by_name user_name
    assert_not_nil @user
    @portfolio = @user.portfolio
    assert_not_nil @portfolio    
    assert_response :success
    assert_equal "User #{@user.name} was successfully created.", flash[:notice]
    
    post_via_redirect "/sessions", :name => @user.name,
                                   :password => password
    assert_equal @user.id, session[:user_id]
    assert_response :success
    
    assert_equal 0, @user.portfolio.trade_orders.length
    assert_equal 250000.00, @portfolio.cash
    
    get "/trade_orders/new"
    assert_response :success
    
    post "/trade_orders", :trade_order => {:is_limit => false, 
                                           :ticker => "MS", 
                                           :quantity => 40, 
                                           :is_buy => true,
                                           :is_long => true}
    assert_redirected_to "/portfolios/#{@portfolio.id}"
    assert 1, @user.portfolio.trade_orders.length
    
    delete "/sessions/1"
    assert_redirected_to "/sessions/new"
    assert_equal nil, session[:user_id]
  end
end
