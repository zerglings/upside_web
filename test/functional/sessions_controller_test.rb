require 'test_helper'

class SessionsControllerTest < ActionController::TestCase  
  fixtures :users
  
  def setup
    @user = users :rich_kid
    @password = 'password'
  end
  
  def test_index_without_user
    get :index
    assert_redirected_to :action => :new
  end
  
  def test_index_with_valid_user
    get :index, {}, { :user_id => users(:rich_kid).id }
    assert_redirected_to :controller => :welcome, :action => :dashboard
  end
  
  def test_login_good_user_and_password
    post :create, :name => @user.name, :password => @password
    assert_redirected_to :controller => :welcome, :action => :dashboard
    assert_equal @user.id, session[:user_id]
  end
  
  def test_bad_password
    post :create, :name => @user.name, :password => 'wrong'
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
  
  def test_xml_login
    post :create, :name => @user.name, :password => @password, :format => 'xml'
    assert_equal @user.id, session[:user_id], "Session not set properly"
    assert_select "user" do
      assert_select "model_id", @user.id.to_s
      assert_select "name", @user.name
      assert_select "is_pseudo_user", "false"
    end
    
    post :create, :name => @user.name, :password => "wrong", :format => 'xml'
    assert_equal nil, session[:user_id], "Session not set properly"
    assert_select "error" do
      assert_select "reason", "auth"
      assert_select "message"
    end
  end
end
