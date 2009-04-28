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
    golden = "f653ce12ff62ff3d5cc077b5380e3fb566f85c7266790b3db603501a0ed87fdf"
    assert_equal golden, ClientCrypto::IphoneFprints.app_fprint(@device_attrs)
  end
  
  def test_app_fprint_without_data
    attrs2 = @device_attrs.merge 'app_version' => '1.1'
    assert_equal '', ClientCrypto::IphoneFprints.app_fprint(attrs2)
  end
  
  def test_app_fprint_with_device_model
    golden = "68b2708e6663c805df64f5ad06a553decb8f7fea3be00d9b729c59cdc3e7da47"
    assert_equal golden, ClientCrypto::IphoneFprints.app_fprint(@device)
  end
end
