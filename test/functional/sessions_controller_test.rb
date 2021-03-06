require 'test_helper'

class SessionsControllerTest < ActionController::TestCase  
  fixtures :users
  
  def setup
    @request.remote_addr = @remote_ip = '666.13.37.911'
    @user = users :rich_kid
    @password = 'password'
    @device = devices :iphone_3g
    @other_device = devices :ipod_touch_2g 
  end
  
  def test_index_without_user
    get :index
    assert_redirected_to :controller => :sessions, :action => :new
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
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id],
                 "User entered incorrect password but session was still set"
  end
  
  def test_bad_user
    post :create, :name => "wrong", :password => 'wrong'
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id],
                 "Nonexistent user but session was still set"
  end
  
  def test_logout
    delete :destroy
    assert_redirected_to :action => :new
    assert_equal nil, session[:user_id],
                 "Session not set to nil even though user logged out"
    assert_equal "Logged out", flash[:notice]
  end
  
  def test_json_login_with_device_info
    impossible_device_info = { :hardware_model => 'iPhone3,1',
                               :unique_id => @device.unique_id,
                               :os_name => 'Awesome OS',
                               :os_version => 'V1',
                               :last_ip => 'fail',
                               :app_version => '1000.0' }
    
    post :create, :name => @user.name, :password => @password,
         :format => 'json', :app_sig => '5678' * 16,
         :device => { :model_id => 0 }.merge(impossible_device_info)         
    assert_equal @user.id, session[:user_id], "Session not set properly"

    result = JSON.parse(@response.body)
    assert result, 'Response contains JSON'
    assert_equal @user.id, result['user']['model_id'], 'User id'
    assert_equal @user.name, result['user']['name'], 'Username'
    assert_equal false, result['user']['is_pseudo_user'], 'Pseudo-user'


    @device.reload
    impossible_device_info.each do |key, value|
      # last_ip is set to some bogus value, to ensure that the controller will
      # overwrite any bogus values it receives. The proper value is checked
      # right after the loop.
      next if key == :last_ip
      
      assert_equal value, @device.send(key),
                   "Logging in did not update device #{key}"
    end
    assert_equal @remote_ip, @device.last_ip,
                 'Logging in did not update device last_ip correctly'
    assert_equal '5678' * 16, @device.last_app_fprint,
                 'Logging in did not update device last_app_fprint correctly'
    
    impossible_device_info[:unique_id] = @other_device.unique_id
    post :create, :name => @user.name, :password => "wrong", :format => 'json',
         :device => { :model_id => 0 }.merge(impossible_device_info)
    assert_equal nil, session[:user_id], "Session not set properly"

    result = JSON.parse(@response.body)
    assert result, 'Response contains JSON'
    assert_equal 'auth', result['error']['reason'], 'Error reason'
    assert result['error']['message'], 'The error has a message'
    @other_device.reload
    impossible_device_info.each do |key, value|
      next if key == :unique_id  # the unique ID will match, nothing else should
      assert_not_equal value, @other_device.send(key),
                       "Failed login mistakenly updated device #{key}"
    end
  end
  
  def test_json_login_with_software_0_9
    # TODO(overmind): remove this once client 0.9 is phased out by 0.10, and
    #                 we don't need to test for the server-side hack    
    impossible_device_info = { :hardware_model => 'iPhone3,1',
                               :unique_id => @device.unique_id,
                               :os_name => 'Awesome OS',
                               :os_version => 'V1',
                               :last_ip => 'fail',
                               :app_provisioning => 'h',
                               :app_version => '1.8' }
    
    post :create, :name => @user.name, :password => @password,
         :format => 'json', :app_sig => '5678' * 16,
         :device => { :model_id => 0 }.merge(impossible_device_info)         
    assert_equal @user.id, session[:user_id], "Session not set properly"

    result = JSON.parse(@response.body)
    assert result, 'Response contains JSON'

    @device.reload
    assert_equal 'D', @device.app_provisioning,
                 'App provisioning for StockPlay 0.9 was not hotfixed'
  end
  
  def test_json_login_with_software_0_7
    impossible_device_info = { :hardware_model => 'iPhone3,1',
                               :unique_id => @device.unique_id,
                               :os_name => 'Awesome OS',
                               :os_version => 'V1',
                               :last_ip => 'fail',
                               :app_version => '1.6' }
    
    post :create, :name => @user.name, :password => @password,
         :format => 'json', :app_sig => '5678' * 16,
         :device => { :model_id => 0 }.merge(impossible_device_info)         
    assert_equal nil, session[:user_id], "Old app version not rejected"

    result = JSON.parse(@response.body)
    assert result, 'Response contains JSON'
    assert_equal 'oldcode', result['error']['reason'], 'Bad error reason'
  end  

  def test_xml_login_with_software_0_5
    impossible_device_info = { :hardware_model => 'iPhone3,1',
                               :unique_id => @device.unique_id,
                               :os_name => 'Awesome OS',
                               :os_version => 'V1',
                               :last_ip => 'fail',
                               :app_version => '1.4' }    
    post :create, :name => @user.name, :password => @password, :format => 'xml',
         :device => { :model_id => 0 }.merge(impossible_device_info)
         
    assert_equal nil, session[:user_id], "Old app version not rejected"
    assert_select 'error' do
      assert_select 'reason', 'oldcode'
    end
  end

  def test_xml_login_with_software_0_1
    post :create, :name => @user.name, :password => @password, :format => 'xml',
                  :device_id => @device.unique_id
    
    assert_equal nil, session[:user_id], "Old app version not rejected"
    assert_select 'error' do
      assert_select 'reason', 'oldcode'
    end
  end
end
