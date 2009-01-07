require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  
 fixtures :users
 
  def test_index_without_user
    get :index
    assert_redirected_to :action => "login"
    assert_equal "Please log in", flash[:error]
  end
  
  def test_index_with_user
    get :index, {}, { :user_id => users(:one).id }
    assert_response :success
    assert_template "index"
  end
  
  def test_login_good_user_and_password
    one = users(:one)
    post :login, :name => one.name, :password => 'password'
    assert_redirected_to :action => "index"
    assert_equal one.id, session[:user_id]
  end
  
  def test_bad_password
    one = users(:one)
    post :login, :name => one.name, :password => 'wrong'
    assert_template "login"
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id], "User entered incorrect password but session was still set"
  end
  
  def test_bad_user
    post :login, :name => "wrong", :password => 'wrong'
    assert_template "login"
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id], "Nonexistent user but session was still set"
  end
  
  def test_logout
    get :logout
    assert_redirected_to :action=> "login"
    assert_equal nil, session[:user_id], "Session not set to nil even though user logged out"
    assert_equal "Logged out", flash[:notice]
  end
end
