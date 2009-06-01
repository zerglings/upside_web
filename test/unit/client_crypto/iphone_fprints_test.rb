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
    golden = "c1493dcf5acf7eecc2b80612d1864158ce1c3ef87d6b4184a809ddc263900a75"
    assert_equal golden, ClientCrypto::IphoneFprints.app_fprint(@device_attrs)
  end
  
  def test_app_fprint_without_data
    attrs2 = @device_attrs.merge 'app_version' => '1.1'
    assert_equal '', ClientCrypto::IphoneFprints.app_fprint(attrs2)
  end
  
  def test_app_fprint_with_device_model
    golden = "758d27a4e1309028e127b3061baaa156a5642acd0c63f233b564f1fe964151d4"
    assert_equal golden, ClientCrypto::IphoneFprints.app_fprint(@device)
  end
end
