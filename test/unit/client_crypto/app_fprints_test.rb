require 'test_helper'

class ClientCrypto::AppFprintsTest < ActiveSupport::TestCase
  def setup
    @device_attrs = {
      'hardware_model'=>'iPhone1,1',
      'unique_id'=>'70e9bcfdaaaafac69a2ef8735a74eeddc32bc2cf',
      'app_version'=>'1.5',
      'os_name'=>'iPhone OS',
      'os_version'=>'3.0'
    }    
  end
  
  def test_fprint_data_directory
    dir = ClientCrypto::AppFprints.fprint_data_directory @device_attrs
    assert_equal "#{RAILS_ROOT}/client_fprint/iphone_os/1.5", dir
  end  
end
