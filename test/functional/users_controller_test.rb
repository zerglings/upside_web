require 'test_helper'

module CommonUserControllerTests
  def common_setup
    @request.session[:user_id] = @user.id
    @portfolio = @user.portfolio
  end
  
  def assert_access_denied
    assert_redirected_to :controller => :welcome, :action => :dashboard
    assert_equal "Admin access only.", flash[:error]
  end
end

class AdminUsersControllerTest < ActionController::TestCase
  include CommonUserControllerTests
  tests UsersController  
  fixtures :users, :portfolios
  
  def setup
    @user = users(:admin)  
    common_setup
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
  
  test "should get index" do
    get :index
    assert_response :success
  end
  
  test "should get new" do
    get :new
    assert_response :success
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
    assert_redirected_to users(:rich_kid).portfolio
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:rich_kid).id
    end

    assert_redirected_to users_path
  end

end

class UsersControllerTest < ActionController::TestCase
  include CommonUserControllerTests
  fixtures :users, :portfolios
  
  def setup
    @user = users(:rich_kid)
    common_setup
  end
  
  test "user not authorized to get index" do
    get :index
    assert_access_denied
  end
  
  test "user not authorized to get new" do
    get :new
    assert_access_denied
  end
  
  test "user not authorized to show" do
    get :show, :id => users(:rich_kid).id
    assert_access_denied
  end
  
  test "user not authorized to create user" do
    post :create, :user => {:name => "createuser",
                            :password => "blah",
                            :password_confirmation => "blah"}
    user = User.find_by_name "createuser"
    assert_nil user, "User was created"
    assert_access_denied             
  end
  
  test "user not authorized to get edit" do
    get :edit, :id => users(:rich_kid).id
    assert_access_denied
  end

  test "user not authorized to update user" do
    put :update, :id => users(:rich_kid).id, :user => { }
    assert_access_denied
  end

  test "user not authorized to destroy user" do
    assert_difference('User.count', 0) do
      delete :destroy, :id => users(:rich_kid).id
    end

    assert_access_denied
  end

  def test_is_admin_set_to_true_if_user_name_is_admin
    @request.session[:user_id] = nil
    post :create, :user => {:name => "admin",
                            :password => "moof",
                            :password_confirmation => "moof"}
    user = User.find_by_name "admin"
    assert_not_nil user, "User was not created."
    assert_equal true, user.is_admin
  end
  
  def test_is_user_taken
    @request.session[:user_id] = nil
    get :is_user_taken, :user => { :name => 'rich_kid' },
                        :callback => 'callbackProc', :format => 'json'
    assert_response :success
    p @response
    json_match = /^callbackProc\((.*)\)$/.match @response.body
    assert json_match, "Response not in JSONP format: #{@response.body}"    
    response = JSON.parse json_match[1]    
    assert_equal({'result' => {'name' => 'rich_kid', 'taken' => true}},
                 response, 'Querying for existing user name')
                 
    get :is_user_taken, :user => { :name => 'poor_kid' }, :format => 'json'
    response = JSON.parse @response.body    
    assert_equal({'result' => {'name' => 'poor_kid', 'taken' => false}},
                 response, 'Querying for non-existing user name')
  end
  
 # TODO(anyone): add this test back in once we allow users to create accounts on the web
=begin  
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
=end
end
