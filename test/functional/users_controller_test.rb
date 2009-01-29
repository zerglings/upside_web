require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  def test_web_users_not_pseudo_users
    post :create, :user => {:name => "createuser",
                            :password => "blah",
                            :password_confirmation => "blah"}
    user = User.find_by_name "createuser"
    assert_not_nil user, "User was not created"
    assert_redirected_to :controller => :sessions, :action => :new
    assert_equal false, user.pseudo_user               
  end
  
  def test_is_admin_not_set_by_mass_assignment
    post :create, :user => {:name => "orange",
                            :password => "juice",
                            :password_confirmation => "juice",
                            :is_admin => true}
    user = User.find_by_name "orange"
    assert_not_nil user, "User was not created."
    assert_equal false, user.is_admin
    put :update, :id => user.id, :user => {:name => "orange",
                                           :password => "juice",
                                           :password_confirmation => "juice",
                                           :is_admin => true}
    assert_equal false, user.is_admin
  end
  
  def test_is_admin_set_to_true_if_user_name_is_admin
    post :create, :user => {:name => "admin",
                            :password => "moof",
                            :password_confirmation => "moof"}
    user = User.find_by_name "admin"
    assert_not_nil user, "User was not created."
    assert_equal true, user.is_admin
    user.is_admin = false
    assert_equal false, user.is_admin
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
