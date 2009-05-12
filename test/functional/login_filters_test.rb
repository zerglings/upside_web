require 'test_helper'

# Fake controller for testing the login filters.
class LoginFiltersController < ActionController::Base
  include LoginFilters
  before_filter :ensure_user_authenticated, :only => [:login_requested]
  
  def login_requested
    respond_to do |format|
      format.html { render :text => "ok" }
      format.json { render :json => {:user => @s_user.id} }
      format.xml { render :xml => {:user => @s_user.id} }
    end
  end
end


class LoginFiltersControllerTest < ActionController::TestCase
  tests LoginFiltersController
  fixtures :users
  
  def setup
    @rich_kid = users(:rich_kid)
    @invalid_id = 911
  end
  
  test "logged in users get variable and contents" do
    get :login_requested, {}, {:user_id => @rich_kid.id}
    assert_response :success
    assert_equal @rich_kid, assigns(:s_user)
  end
  
  test "json logins work as well" do
    get :login_requested, {:format => 'json'}, {:user_id => @rich_kid.id}
    assert_response :success
    assert_equal @rich_kid, assigns(:s_user)
    result = JSON.parse @response.body
    assert_equal @rich_kid.id, result['user']
  end

  test "xml logins work as well" do
    get :login_requested, {:format => 'xml'}, {:user_id => @rich_kid.id}
    assert_response :success
    assert_equal @rich_kid, assigns(:s_user)
    assert_select "user", @rich_kid.id.to_s
  end
  
  test "anonymous html requests get redirected" do
    get :login_requested
    assert_response :redirect
    assert_redirected_to :controller => :sessions, :action => :new
    assert_nil assigns(:s_user)
  end
  
  test "anonymous json requests get proper response" do    
    get :login_requested, :format => 'json', :callback => 'callbackFn'    
    assert_response :success
    response_match = /callbackFn\((.*)\)/.match @response.body
    assert response_match, 'Response not in JSONP format'
    result = JSON.parse response_match[1]
    assert result['error'], 'JSON response does not include error'
    assert_equal 'login', result['error']['reason'],
                 'JSON response contains wrong error reason'
    assert_nil assigns(:s_user)
  end

  test "anonymous xml requests get proper response" do    
    get :login_requested, :format => 'xml'
    assert_response :success
    assert_select "error" do
      assert_select "reason", "login"
    end
    assert_nil assigns(:s_user)
  end
  
  test "invalid user IDs don't crash" do
    get :login_requested, {}, {:user_id => @invalid_user_id}
    assert_response :redirect
    get :login_requested, {:format => 'xml'}, {:user_id => @invalid_user_id}
    assert_response :success
    assert_select "error" do
      assert_select "reason", "login"
    end
  end
end
