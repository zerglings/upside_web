require 'test_helper'

class DeviceTest < ActiveSupport::TestCase

  def setup
    @device = Device.new :unique_id => '12345' * 8,
                         :hardware_model => 'iPod1,1',
                         :os_name => 'iPhone OS',
                         :os_version => '2.1',
                         :app_id => 'us.costan.ZergSupport',
                         :app_provisioning => 'D',
                         :app_push_token => nil,
                         :app_version => '1.0',
                         :last_activation => Time.now - 2.days,
                         :user_id => users(:rich_kid).id,
                         :last_ip => '127.9.5.33',
                         :last_app_fprint => '1234' * 16
  end
  
  def test_setup_valid
    assert @device.valid?
  end
  
  def test_unique_id_uniqueness
    @device.unique_id = devices(:iphone_3g).unique_id
    assert !@device.valid?
  end
  
  def test_unique_id_length
    @device.unique_id = "12345" * 7
    assert !@device.valid?
  end
  
  def test_unique_id_presence
    @device.unique_id = nil
    assert !@device.valid?
  end
  
  def test_hardware_model_length
    @device.hardware_model = "12345" * 7
    assert !@device.valid?
  end
  
  def test_hardware_model_presence
    @device.hardware_model = nil
    assert !@device.valid?
  end

  def test_os_name_length
    @device.os_name = "12345" * 7
    assert !@device.valid?
  end
  
  def test_os_name_presence
    @device.os_name = nil
    assert !@device.valid?
  end

  def test_os_version_length
    @device.os_version = "12345" * 7
    assert !@device.valid?
  end
  
  def test_os_version_presence
    @device.os_version = nil
    assert !@device.valid?
  end
    
  def test_app_id_length
    @device.app_id ="12345" * 12
    assert @device.valid?
    
    @device.app_id ="12345" * 13
    assert !@device.valid?
  end
  
  def test_app_id_presence
    @device.app_id = nil
    assert !@device.valid?
  end
  
  def test_app_provisioning_length
    @device.app_provisioning = 'S3x'
    assert @device.valid?
    
    @device.app_provisioning = '12345'
    assert !@device.valid?
  end
  
  def test_app_provisioning_presence
    @device.app_provisioning = nil
    assert !@device.valid?
  end
  
  def test_app_push_token_can_be_nil
    @device.app_push_token = nil
    assert @device.valid?
  end
  
  def test_app_push_token_can_be_empty
    @device.app_push_token = ''
    assert @device.valid?
    
    assert_equal nil, @device.app_push_token,
                 'Empty push token should be converted to nil'
  end
  
  def test_app_push_token_length
    @device.app_push_token = "12345" * 51
    assert @device.valid?
    @device.app_push_token = "12345" * 52
    assert !@device.valid?
  end

  def test_app_version_length
    @device.app_version = "12345" * 4
    assert !@device.valid?
  end
  
  def test_app_version_presence
    @device.app_version = nil
    assert !@device.valid?
  end

  def test_last_activation_presence
    @device.last_activation = nil
    assert !@device.valid?
  end
  
  def test_last_activation_format
    @device.last_activation = "blah"
    assert !@device.valid?
  end
  
  def test_user_id_presence
    @device.user_id = nil
    assert !@device.valid?
  end
  
  def test_last_ip_presence
    @device.last_ip = nil
    assert !@device.valid?    
  end

  def test_last_ip_length
    @device.last_ip = "12345" * 13
    assert !@device.valid?
  end

  def test_last_app_fprint_presence
    @device.last_app_fprint = nil
    assert !@device.valid?    
  end

  def test_last_app_fprint_length
    @device.last_app_fprint = ''
    assert @device.valid?, 'Empty finger-prints should be OK'

    @device.last_app_fprint = "12345" * 13
    assert !@device.valid?, 'Longer than 64 characters'
  end
end
