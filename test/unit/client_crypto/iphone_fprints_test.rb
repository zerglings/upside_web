require 'test_helper'

class ClientCrypto::IphoneFprintsTest < ActiveSupport::TestCase
  fixtures :devices
  
  def setup
    @device_attrs = {
      'hardware_model'=>'iPhone1,1',
      'unique_id'=>'70e9bcfdaaaafac69a2ef8735a74eeddc32bc2cf',
      'app_version'=>'1.5',
      'os_name'=>'iPhone OS',
      'os_version'=>'3.0'
    }
    @device = devices :iphone_3g
  end
    
  def test_app_fprint
    golden = "d1a0f14ad9c6de919b0e855c7e52e83f7b432f84f760244255198cfef1b99032"
    assert_equal golden, ClientCrypto::IphoneFprints.app_fprint(@device_attrs)
  end
  
  def test_app_fprint_without_data
    attrs2 = @device_attrs.merge 'app_version' => '1.1'
    assert_equal '', ClientCrypto::IphoneFprints.app_fprint(attrs2)
  end
  
  def test_app_fprint_with_device_model
    golden = "fcb51a1c0f7dc04e7e45b2f0779ab48eddfcc2bbd7699230e427988ff6f8a245"
    assert_equal golden, ClientCrypto::IphoneFprints.app_fprint(@device)
  end
end
