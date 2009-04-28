require 'test_helper'

class ClientCrypto::AppFprintsTest < ActiveSupport::TestCase
  def setup
    @device_attrs = {
      'hardware_model'=>'iPhone1,1',
      'unique_id'=>'70e9bcfdaaaafac69a2ef8735a74eeddc32bc2cf',
      'app_version'=>'1.2',
      'os_name'=>'iPhone OS',
      'os_version'=>'3.0'
    }    
  end
  
  def test_fprint
    dir = ClientCrypto::AppFprints.fprint_data_directory @device_attrs
    assert_equal "#{RAILS_ROOT}/client_fprint/iphone_os/1.2", dir
  end
  
  def test_device_fprint
    hex_fprint = ClientCrypto::AppFprints.device_fprint(@device_attrs).
        unpack('C*').map { |c| "%02x" % c }.join
    assert_equal '66547ef853f8455e6b2f99b237faa57f', hex_fprint
  end
  
  def test_file_data_fprint
    golden = "f653ce12ff62ff3d5cc077b5380e3fb566f85c7266790b3db603501a0ed87fdf"
    
    data = File.read "#{RAILS_ROOT}/client_fprint/iphone_os/1.2/Info.plist"
    key = (0..16).map { |i| '66547ef853f8455e6b2f99b237faa57f'[i * 2, 2] }.
                  map { |s| s.to_i(16) }.pack('C*')
    
    file_fprint = ClientCrypto::AppFprints.file_data_fprint data, key
    assert_equal golden, file_fprint 
  end
end
