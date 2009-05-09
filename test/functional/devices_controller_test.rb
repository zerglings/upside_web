require 'digest/sha2'
require 'test_helper'

class AdminDevicesControllerTest < ActionController::TestCase
  fixtures :devices, :users
  tests DevicesController
  
  def setup
    @request.session[:user_id] = users(:admin)
  end
  
  test "admin should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:devices)
  end
  
  test "admin should get new" do
    get :new
    assert_response :success
  end
  
  test "admin should create device" do
    assert_difference('Device.count') do
      post :create, :device => { :unique_id => "12345" * 8,
                                 :last_activation => Time.now,
                                 :user_id => users(:device_user).id,
                                 :hardware_model => 'iPhone1,1',
                                 :os_name => 'iPhone OS',
                                 :os_version => '2.0',
                                 :app_version => '1.0' }
    end

    assert_redirected_to device_path(assigns(:device))
  end

  test "admin should show device" do
    get :show, :id => devices(:iphone_3g).id
    assert_response :success
  end

  test "admin should get edit" do
    get :edit, :id => devices(:iphone_3g).id
    assert_response :success
  end

  test "admin should update device" do
    put :update, :id => devices(:iphone_3g).id, :device => { }
    assert_redirected_to device_path(assigns(:device))
  end

  test "admin should destroy device" do
    assert_difference('Device.count', -1) do
      delete :destroy, :id => devices(:iphone_3g).id
    end

    assert_redirected_to devices_path
  end
end

class UserDevicesControllerTest < ActionController::TestCase
  fixtures :devices, :users
  tests DevicesController
  
  def setup
    @user = users(:rich_kid)
    @request.session[:user_id] = @user
    @portfolio = @user.portfolio
  end
  
  def assert_access_denied
    assert_redirected_to :controller => :welcome, :action => :dashboard
    assert_equal "Admin access only.", flash[:error]
  end
  
  test "user not authorized to get index" do
    get :index
    assert_access_denied
  end
  
  test "user not authorized to get new" do
    get :new
    assert_access_denied
  end
  
  test "user not authorized to create device" do
    count_before = Device.count
      post :create, :device => { :unique_id => "12345" * 8,
                                 :last_activation => Time.now,
                                 :user_id => users(:device_user).id,
                                 :hardware_model => 'iPhone1,1',
                                 :os_name => 'iPhone OS',
                                 :os_version => '2.0',
                                 :app_version => '1.0' }
    count_after = Device.count
    assert_equal 0, count_after - count_before
    assert_access_denied
  end

  test "user not authorized to show device" do
    get :show, :id => devices(:iphone_3g).id
    assert_access_denied
  end

  test "user not authorized to get edit" do
    get :edit, :id => devices(:iphone_3g).id
    assert_access_denied
  end

  test "user not authorized to update device" do
    put :update, :id => devices(:iphone_3g).id, :device => { }
    assert_access_denied
  end

  test "user not authoried to destroy device" do
    count_before = Device.count
    delete :destroy, :id => devices(:iphone_3g).id
    count_after = Device.count
    assert_equal 0, count_after - count_before
    assert_access_denied
  end
end

class DevicesControllerTest < ActionController::TestCase
  fixtures :devices, :users
  
  def setup    
    @request.remote_addr = @remote_ip = '666.13.37.911'
    device1 = devices(:iphone_3g)
    device1.user = users(:rich_kid)
    device1.save!
  end
  
  test "register new device with v0.3" do
    unique_id = '88888' * 8
    post :register, :unique_id => unique_id, :format => 'xml',
                    :device_sig => IphoneAuthFilters.signature(unique_id),
                    :device_sig_v => IphoneAuthFilters.signature_version,
                    :device => { :unique_id => unique_id,
                                 :model_id => 0,
                                 :user_id => 0,
                                 :hardware_model => 'iPhone1,1',
                                 :app_version => '1.2',
                                 :os_name => 'iPhone OS',
                                 :os_version => '2.1' },
                    :app_sig => '1234' * 16
    device = Device.find_by_unique_id unique_id
    assert_not_nil device, "Device not created when registering a new device"
    assert_equal unique_id, device.unique_id
    assert_equal @remote_ip, device.last_ip,
                 "Device's last IP recorded incorrectly"
    assert_equal '1234' * 16, device.last_app_fprint,
                 "Device's last app finger-print not updated correctly"
    user = device.user
    assert_not_nil user, "User not created when registering a new device"
    assert user.pseudo_user?, "New device's user should be a pseudo-user"
    assert_equal Digest::SHA2.hexdigest(unique_id), user.name,
                 "New user's name should be the SHA2 of the device's UDID."
    assert_operator (Time.now - device.last_activation).abs, :<=, 2,
                    "Last activation time was not set properly"
    
    assert_select "device" do
      assert_select "model_id", device.id.to_s
      assert_select "unique_id", unique_id
      assert_select "user_id", user.id.to_s
      assert_select "hardware_model", 'iPhone1,1'
      assert_select "app_version", '1.2'
      assert_select "os_name", 'iPhone OS'
      assert_select "os_version", '2.1'
    end
    
    assert_select "user" do
      assert_select "model_id", user.id.to_s
      assert_select "name", user.name
      assert_select "is_pseudo_user", "true"
    end
  end  

  test "register new device with v0.2" do
    # TODO(overmind): this is an almost-duplicate of the code above; remove it
    #                 when 0.3 is in store and we can retire 0.1 and 0.2
    
    unique_id = '88888' * 8
    post :register, :unique_id => unique_id, :format => 'xml',
                    :device_sig => IphoneAuthFilters.signature(unique_id),
                    :device_sig_v => IphoneAuthFilters.signature_version,
                    :device => { :unique_id => unique_id,
                                 :model_id => 0,
                                 :user_id => 0,
                                 :hardware_model => 'iPhone1,1',
                                 :app_version => '1.1',
                                 :os_name => 'iPhone OS',
                                 :os_version => '2.1' } 
    device = Device.find_by_unique_id unique_id
    assert_not_nil device, "Device not created when registering a new device"
    assert_equal unique_id, device.unique_id
    assert_equal @remote_ip, device.last_ip,
                 "Device's last IP recorded incorrectly"
    assert_equal '', device.last_app_fprint, "Device's last app finger-print"
    user = device.user
    assert_not_nil user, "User not created when registering a new device"
    assert user.pseudo_user?, "New device's user should be a pseudo-user"
    assert_equal Digest::SHA2.hexdigest(unique_id), user.name,
                 "New user's name should be the SHA2 of the device's UDID."
    assert_operator (Time.now - device.last_activation).abs, :<=, 2,
                    "Last activation time was not set properly"
    
    assert_select "device" do
      assert_select "model_id", device.id.to_s
      assert_select "unique_id", unique_id
      assert_select "user_id", user.id.to_s
      assert_select "hardware_model", 'iPhone1,1'
      assert_select "app_version", '1.1'
      assert_select "os_name", 'iPhone OS'
      assert_select "os_version", '2.1'
    end
    
    assert_select "user" do
      assert_select "model_id", user.id.to_s
      assert_select "name", user.name
      assert_select "is_pseudo_user", "true"
    end
  end

  test "register new device with v0.1" do
    unique_id = '88888' * 8    
    post :register, :unique_id => unique_id, :format => 'xml',
                    :device_sig => IphoneAuthFilters.signature(unique_id),
                    :device_sig_v => IphoneAuthFilters.signature_version
    device = Device.find_by_unique_id unique_id
    assert_not_nil device, "Device not created when registering a new device"
    assert_equal unique_id, device.unique_id
    assert_equal @remote_ip, device.last_ip,
                 "Device's last IP recorded incorrectly"
    assert_equal '', device.last_app_fprint, "Device's last app finger-print"                 
    user = device.user
    assert_not_nil user, "User not created when registering a new device"
    assert user.pseudo_user?, "New device's user should be a pseudo-user"
  end  
  
  test "try registering existing device" do
    old_user_count = User.count
    old_device_count = Device.count
    iphone_3g = devices(:iphone_3g)
    unique_id = iphone_3g.unique_id
    post :register, :unique_id => unique_id, :format => 'xml',
                    :device_sig => IphoneAuthFilters.signature(unique_id),
                    :device_sig_v => IphoneAuthFilters.signature_version
    assert_equal old_device_count, Device.count, "Registering an existing device created a new device"
    assert_equal old_user_count, User.count, "Registering an existing device created a new user"
   
    assert_equal @remote_ip, iphone_3g.reload.last_ip,
                 "Device's last IP updated incorrectly"
    
    assert_select "device" do
      assert_select "model_id", iphone_3g.id.to_s
      assert_select "unique_id", iphone_3g.unique_id
      assert_select "user_id", iphone_3g.user_id.to_s
    end
    
    assert_select "user" do
      assert_select "model_id", iphone_3g.user.id.to_s
      assert_select "name", iphone_3g.user.name
      assert_select "is_pseudo_user", "false"
    end    
  end
  
  test "registration bounces without signature" do
    old_user_count = User.count
    old_device_count = Device.count
    iphone_3g = devices(:iphone_3g)
    unique_id = iphone_3g.unique_id
    post :register, :unique_id => unique_id, :format => 'xml',
                    :device_sig_v => IphoneAuthFilters.signature_version
    assert_select "error" do
      assert_select "reason", "device_auth"
    end
  end
end
