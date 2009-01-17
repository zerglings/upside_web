require 'test_helper'

class TradesControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trades)
  end
  
=begin
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trade" do
    assert_difference('Trade.count') do
      post :create, :trade => { }
    end

    assert_redirected_to trade_path(assigns(:trade))
  end

  test "should show trade" do
    get :show, :id => trades(:normal_trade).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => trades(:normal_trade).id
    assert_response :success
  end

  test "should update trade" do
    put :update, :id => trades(:normal_trade).id, :trade => { }
    assert_redirected_to trade_path(assigns(:trade))
  end

  test "should destroy trade" do
    assert_difference('Trade.count', -1) do
      delete :destroy, :id => trades(:normal_trade).id
    end

    assert_redirected_to trades_path
  end
=end
end
