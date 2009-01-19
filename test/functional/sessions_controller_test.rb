require 'test_helper'

class SessionsControllerTest < ActionController::TestCase  
  fixtures :users
  
  def test_index_without_user
    get :index
    assert_redirected_to :action => :new
    assert_equal "Please log in", flash[:error]
  end
  
  def test_index_with_user
    get :index, {}, { :user_id => users(:rich_kid).id }
    assert_response :success
    assert_template "index"
  end
  
  def test_login_good_user_and_password
    one = users(:rich_kid)
    post :create, :name => one.name, :password => 'password'
    assert_redirected_to :controller => :portfolios, :action => one.id
    assert_equal one.id, session[:user_id]
  end
  
  def test_bad_password
    one = users(:rich_kid)
    post :create, :name => one.name, :password => 'wrong'
    assert_template "new"
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id], "User entered incorrect password but session was still set"
  end
  
  def test_bad_user
    post :create, :name => "wrong", :password => 'wrong'
    assert_template "new"
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id], "Nonexistent user but session was still set"
  end
  
  def test_logout
    delete :destroy
    assert_redirected_to :action => :new
    assert_equal nil, session[:user_id], "Session not set to nil even though user logged out"
    assert_equal "Logged out", flash[:notice]
  end
end
