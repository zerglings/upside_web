require 'test_helper'

class AdminWarningFlagsControllerTest < ActionController::TestCase
  fixtures :warning_flags, :users
  tests WarningFlagsController
  
  def setup
    @request.session[:user_id] = users(:admin)
  end

  test "admin should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:warning_flags)
  end

  test "admin should show warning_flag" do
    get :show, :id => warning_flags(:rich_kid_doing_well).to_param
    assert_response :success
  end

  test "admin should destroy warning_flag" do
    assert_difference('WarningFlag.count', -1) do
      delete :destroy, :id => warning_flags(:rich_kid_doing_well).to_param
    end

    assert_redirected_to warning_flags_path
  end
end

class UserWarningFlagsControllerTest < ActionController::TestCase
  fixtures :warning_flags, :users
  tests WarningFlagsController
  
  def setup
    @user = users(:rich_kid)
    @request.session[:user_id] = @user
  end
  
  def assert_access_denied
    assert_redirected_to :controller => :welcome, :action => :dashboard
    assert_equal "Admin access only.", flash[:error]
  end
  
  test "user not authorized to get index" do
    get :index
    assert_access_denied
  end

  test "user not authorized to show warning_flag" do
    get :show, :id => warning_flags(:rich_kid_doing_well).to_param
    assert_access_denied
  end

  test "user not authorized to destroy warning_flag" do
    assert_difference('WarningFlag.count', 0) do
      delete :destroy, :id => warning_flags(:rich_kid_doing_well).to_param
    end
    assert_access_denied
  end
end
