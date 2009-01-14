require 'test_helper'

class DeviceTest < ActiveSupport::TestCase

  def setup
    @device = Device.new(:unique_id => "12345" * 8, :last_activation => "2009-01-01 16:44:49", :user_id => users(:one).id)
  end
  
  def test_setup_valid
    assert @device.valid?
  end
  
  def test_unique_id_uniqueness
    @device.unique_id = devices(:one).unique_id
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
end
