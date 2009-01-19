require 'test_helper'


class DevicesControllerTest < ActionController::TestCase
  fixtures :devices, :users
  
  def setup
    return
    device1 = devices(:iphone_3g)
    device1.user = users(:rich_kid)
    device1.save!
  end
  
  
  def test_register_new_device
    unique_id = '88888' * 8
    post :register, :unique_id => unique_id, :format => 'xml'
    user = User.find(:first, :conditions => {:name => unique_id})
    assert_not_nil user, "User was not created when registering a new device"
    assert_equal unique_id, user.name
    assert_not_nil User.authenticate(unique_id, unique_id), "Password was set incorrectly when registering a new device"
    device = Device.find(:first, :conditions => {:unique_id => unique_id})  
    assert_not_nil device, "Device was not created when registering a new device"
    assert_equal unique_id, device.unique_id
    assert_operator (Time.now - device.last_activation).abs, :<= , 2, "Last activation time was not set properly"
    assert_equal user, device.user
    
    assert_select "device" do
      assert_select "deviceId", device.id.to_s
      assert_select "uniqueId", unique_id
      assert_select "userId", user.id.to_s
    end
  end  
  
  def test_register_existing_device
    old_user_count = User.count
    old_device_count = Device.count
    post :register, :unique_id => devices(:iphone_3g).unique_id, :format => 'xml'
    assert_equal old_device_count, Device.count, "Registering an existing device created a new device"
    assert_equal old_user_count, User.count, "Registering an existing device created a new user"
    
    assert_select "device" do
      assert_select "deviceId", devices(:iphone_3g).id.to_s
      assert_select "uniqueId", devices(:iphone_3g).unique_id
      assert_select "userId", devices(:iphone_3g).user_id.to_s
    end
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:devices)
  end

=begin
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create device" do
    assert_difference('Device.count') do
      post :create, :device => { }
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
=end
end
