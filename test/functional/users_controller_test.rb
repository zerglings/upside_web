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
    get :edit, :id => @user.id
    assert_access_denied
  end

  test "user not authorized to update other user" do
    put :update, :id => users(:short_lover).id, :user => { }
    assert_access_denied
  end
  
  test "user can change its password" do
    password = 'l33t_k0d3'
    put :update, :id => @user.id, :user => { :password => password }
    assert_redirected_to @portfolio
    
    @user.reload
    assert_equal @user, User.authenticate(@user.name, password),
                 'Password change failed'
  end

  test "named user cannot change its name" do
    put :update, :id => @user.id, :user => { :name => 'rich_kid^^' }
    assert_access_denied
  end

  test "unnamed iphone user upgrades to named" do
    name, password = 'noname', 'pa55w0rd'
    @user = users(:device_user)
    @request.session[:user_id] = @user.id
    put :update, :id => 0, :format => 'json', :callback => 'callbackProc',
        :user => { :name => name, :password => password, :model_id => @user.id }        

    json_match = /^callbackProc\((.*)\)$/.match @response.body
    assert json_match, "Response not in JSONP format: #{@response.body}"
    response = JSON.parse json_match[1]
    
    golden_response = { 'user' => { 'name' => name, 'model_id' => @user.id,
                                    'is_pseudo_user' => false } }
    assert_equal golden_response, response, 'Bad response data'
    
    @user.reload
    assert_equal name, @user.name, 'User rename failed'
    assert_equal @user, User.authenticate(name, password),
                 'Password change failed'
  end
  
  test "unnamed iphone user cannot upgrade to used name" do
    name, password = 'rich_kid', 'pa55w0rd'
    @user = users(:device_user)
    @request.session[:user_id] = @user.id
    put :update, :id => 0, :format => 'json',
        :user => { :name => name, :password => password, :model_id => @user.id }        

    response = JSON.parse @response.body
    assert_equal 'validation', response['error']['reason'],
                 'Reusing a user name should fail validation'
    
    @user.reload
    assert @user.pseudo_user?, 'User should not become named'
  end

  test "named iphone user cannot change name" do
    old_name, old_password = 'rich_kid', 'password'
    name, password = 'noname', 'pa55w0rd'
    put :update, :id => 0, :format => 'json', :callback => 'callbackProc',
        :user => { :name => name, :password => password, :model_id => @user.id }

    json_match = /^callbackProc\((.*)\)$/.match @response.body
    assert json_match, "Response not in JSONP format: #{@response.body}"
    response = JSON.parse json_match[1]
    assert_equal 'denied', response['error']['reason'],
                 'Renaming should be rejected'
    
    @user.reload
    assert_equal old_name, @user.name, 'User name should not change'
    assert_equal @user, User.authenticate(old_name, old_password),
                 'User password should not change'
  end

  test "named iphone user changes password" do
    password = 'l33t_k0d3'
    put :update, :id => 0, :format => 'json', :callback => 'callbackProc',
        :user => { :password => password }

    json_match = /^callbackProc\((.*)\)$/.match @response.body
    assert json_match, "Response not in JSONP format: #{@response.body}"
    response = JSON.parse json_match[1]
    
    golden_user = { 'name' => @user.name, 'model_id' => @user.id,
                    'is_pseudo_user' => false }
    assert_equal golden_user, response['user'], 'Response user data'
    
    @user.reload
    assert_equal @user, User.authenticate(@user.name, password),
                 'Password change failed'
  end
  
  test "user not authorized to destroy user" do
    assert_difference('User.count', 0) do
      delete :destroy, :id => users(:rich_kid).id
    end

    assert_access_denied
  end

  test "is_admin set to true if user_name is admin" do
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
