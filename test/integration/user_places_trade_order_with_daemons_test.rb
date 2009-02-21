require 'test_helper'

class UserPlacesTradeOrderWithDaemonsTest < ActionController::IntegrationTest
  fixtures :users, :portfolios
  
  # If this isn't here, Rails runs the entire test in a transaction. This means
  # the matcher doesn't see anything that happens in here :(
  self.use_transactional_fixtures = false

  test "existing user places trade order and it is filled" do
    TradeOrder.destroy_all
    Trade.destroy_all
    Daemonz.with_daemons do
      @user = users(:rich_kid)
      @portfolio = @user.portfolio
      
      post_via_redirect "/sessions", :name => @user.name,
                                     :password => 'password'
      assert_response :success
      
      post_via_redirect "/trade_orders", :trade_order => {:is_limit => false, 
                                                          :ticker => "MS", 
                                                          :quantity => 40, 
                                                          :is_buy => true,
                                                          :is_long => true}
      assert_response :success
      @portfolio.reload
      @new_order = @portfolio.trade_orders.last
      assert_equal 40, @new_order.quantity, "Incorrect order placed"
      assert !@new_order.is_limit, "Incorrect order placed"

      # Wait 2 seconds for the order to be filled
      20.times do
        sleep 0.1
        @new_order.reload
        break if @new_order.unfilled_quantity != @new_order.quantity
      end
      
      assert_equal 0, @new_order.unfilled_quantity,
                   "Matcher did not fill market buy order"
    end
  end
end
