require 'test_helper'

class SessionsControllerTest < ActionController::TestCase  
  fixtures :users
  
  def setup
    @user = users :rich_kid
    @password = 'password'
    @device = devices :iphone_3g
    @other_device = devices :ipod_touch_2g 
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
  
  def test_xml_login_with_device_info
    impossible_device_info = { :hardware_model => 'iPhone3,1',
                               :unique_id => @device.unique_id,
                               :os_name => 'Awesome OS',
                               :os_version => 'V1' } 
    
    post :create, :name => @user.name, :password => @password, :format => 'xml',
         :device => { :model_id => 0 }.merge(impossible_device_info)
    assert_equal @user.id, session[:user_id], "Session not set properly"
    assert_select "user" do
      assert_select "model_id", @user.id.to_s
      assert_select "name", @user.name
      assert_select "is_pseudo_user", "false"
    end
    @device.reload
    impossible_device_info.each do |key, value|
      assert_equal value, @device.send(key),
                   "Logging in did not update device #{key}"
    end
    
    impossible_device_info[:unique_id] = @other_device.unique_id
    post :create, :name => @user.name, :password => "wrong", :format => 'xml',
         :device => { :model_id => 0 }.merge(impossible_device_info)
    assert_equal nil, session[:user_id], "Session not set properly"
    assert_select "error" do
      assert_select "reason", "auth"
      assert_select "message"
    end
    @other_device.reload
    impossible_device_info.each do |key, value|
      next if key == :unique_id  # the unique ID will match, nothing else should 
      assert_not_equal value, @other_device.send(key),
                       "Failed login mistakenly updated device #{key}"
    end
  end
end
