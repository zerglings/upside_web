require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  def test_web_users_not_pseudo_users
    post :create, :user => {:name => "createuser", :password => "blah", :password_confirmation => "blah"}
    assert_redirected_to :controller => :admin, :action => :login
    user = User.find(:first, 
                     :conditions => {:name => "createuser"})
    assert user, "User was not created"
    assert_equal false, user.pseudo_user               
  end
    
=begin
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, :user => { }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, :id => users(:rich_kid).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => users(:rich_kid).id
    assert_response :success
  end

  test "should update user" do
    put :update, :id => users(:rich_kid).id, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:rich_kid).id
    end

    assert_redirected_to users_path
  end
=end
end
