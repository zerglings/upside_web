require 'test_helper'

# Fake controller for testing the login filters.
class IphoneAuthFiltersController < ActionController::Base
  include IphoneAuthFilters
  before_filter :ensure_iphone_request, :only => [:hello_iphone]
  
  def hello_iphone
    respond_to do |format|
      format.html { render :text => "ok" }
      format.json { render :json => {:udid => @s_unique_device_id} }
      format.xml { render :xml => {:udid => @s_unique_device_id} }
    end
  end
end

class IphoneAuthFiltersControllerTest < ActionController::TestCase
  tests IphoneAuthFiltersController
  
  def setup
    @device_id = '12345' * 8
    @signature = IphoneAuthFilters.signature @device_id
    @version = IphoneAuthFilters.signature_version
  end
  
  test "valid sig works in HTML" do
    get :hello_iphone, :unique_id => @device_id,
                       :device_sig => @signature, :device_sig_v => @version
    assert_response :success
    assert_equal @response.body, "ok"
  end

  test "valid sig works in JSON" do
    get :hello_iphone, :format => 'json', :unique_id => @device_id,
                       :device_sig => @signature, :device_sig_v => @version
    assert_response :success
    result = JSON.parse @response.body
    assert_equal @device_id, result["udid"]
  end

  test "valid sig works in XML" do
    get :hello_iphone, :format => 'xml', :unique_id => @device_id,
                       :device_sig => @signature, :device_sig_v => @version
    assert_response :success
    assert_select "udid", @device_id
  end

  test "invalid sig gives HTTP redirect" do
    @signature[10] = '4'
    get :hello_iphone, :unique_id => @device_id,
                       :device_sig => @signature, :device_sig_v => @version
    assert_response :redirect
  end
  
  test "invalid sig gives JSON error" do
    @signature[10] = '4'
    get :hello_iphone, :format => 'json', :unique_id => @device_id,
                       :device_sig => @signature, :device_sig_v => @version,
                       :callback => 'callbackFn'
    assert_response :success
    response_match = /callbackFn\((.*)\)/.match @response.body
    assert response_match, 'Response not in JSONP format'
    result = JSON.parse response_match[1]
    assert result['error'], 'JSON response does not include error'
    assert_equal 'device_auth', result['error']['reason'],
                 'JSON response contains wrong error reason'
  end

  test "invalid sig gives XML error" do
    @signature[10] = '4'
    get :hello_iphone, :format => 'xml', :unique_id => @device_id,
                       :device_sig => @signature, :device_sig_v => @version
    assert_response :success
    assert_select "error" do
      assert_select "reason", "device_auth"
    end    
  end
  
  test "blank sig doesn't crash" do
    @signature[10] = '4'
    get :hello_iphone
    assert_response :redirect
  end  

  test "incomplete sig doesn't crash" do
    @signature[10] = '4'
    get :hello_iphone
    get :hello_iphone, :unique_id => @device_id, :device_sig_v => @version
    assert_response :redirect, "missing signature"
    get :hello_iphone, :unique_id => @device_id, :device_sig => @signature
    assert_response :redirect, "missing version"
    get :hello_iphone, :device_sig => @valid_sig, :device_sig_v => @version
    assert_response :redirect, "missing device id"
  end
  
  test "wrong version gets rejected" do
    @version[0] = '2'
    get :hello_iphone, :unique_id => @device_id,
                       :device_sig => @signature, :device_sig_v => @version
    assert_response :redirect
  end
end
