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
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create device" do
    assert_difference('Device.count') do
      post :create, :device => {:unique_id => "12345" * 8, :last_activation => Time.now, :user_id => users(:device_user).id }
    end

    assert_redirected_to device_path(assigns(:device))
  end

  test "should show device" do
    get :show, :id => devices(:iphone_3g).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => devices(:iphone_3g).id
    assert_response :success
  end

  test "should update device" do
    put :update, :id => devices(:iphone_3g).id, :device => { }
    assert_redirected_to device_path(assigns(:device))
  end

  test "should destroy device" do
    assert_difference('Device.count', -1) do
      delete :destroy, :id => devices(:iphone_3g).id
    end

    assert_redirected_to devices_path
  end
end

class DevicesControllerTest < ActionController::TestCase
  fixtures :devices, :users
  
  def setup
    device1 = devices(:iphone_3g)
    device1.user = users(:rich_kid)
    device1.save!
  end

  test "register new device" do
    unique_id = '88888' * 8
    post :register, :unique_id => unique_id, :format => 'xml',
                    :device_sig => IphoneAuthFilters.signature(unique_id),
                    :device_sig_v => IphoneAuthFilters.signature_version
    device = Device.find_by_unique_id unique_id
    assert_not_nil device, "Device not created when registering a new device"
    assert_equal unique_id, device.unique_id
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
    end
    
    assert_select "user" do
      assert_select "model_id", user.id.to_s
      assert_select "name", user.name
      assert_select "is_pseudo_user", "true"
    end
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
