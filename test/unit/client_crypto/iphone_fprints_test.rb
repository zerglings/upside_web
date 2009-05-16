require 'test_helper'

class ClientCrypto::IphoneFprintsTest < ActiveSupport::TestCase
  fixtures :devices
  
  def setup
    @device_attrs = {
      'hardware_model'=>'iPhone1,1',
      'unique_id'=>'70e9bcfdaaaafac69a2ef8735a74eeddc32bc2cf',
      'app_version'=>'1.2',
      'os_name'=>'iPhone OS',
      'os_version'=>'3.0'
    }
    @device = devices :iphone_3g
  end
    
  def test_app_fprint
    golden = "f861045b7e3f6bf2c45dbe9da8007b28819e047ce60daa939de5594bb73353ef"
    assert_equal golden, ClientCrypto::IphoneFprints.app_fprint(@device_attrs)
  end
  
  def test_app_fprint_without_data
    attrs2 = @device_attrs.merge 'app_version' => '1.1'
    assert_equal '', ClientCrypto::IphoneFprints.app_fprint(attrs2)
  end
  
  def test_app_fprint_with_device_model
    golden = "1c3c6c732f7508f0299751ec76cd3a222b524bc224131936c0ccd2935d686250"
    assert_equal golden, ClientCrypto::IphoneFprints.app_fprint(@device)
  end
end
