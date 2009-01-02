require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(:name => "buffet", :password_hash => "1234567890", :password_salt => "1234")
  end
  
  def test_user_name_length
    @user.name = "buf"
    assert !@user.valid?
    
    @user.name = "buffetbuffetbuffe"
    assert !@user.valid?
  end
  
  def test_user_name_presence
    @user.name = ""
    assert !@user.valid?
    
    @user.name = nil 
    assert !@user.valid?
  end
  
  def test_user_name_with_spaces
    @user.name = "buf fet"
    assert !@user.valid?
  end
  
  def test_user_name_uniqueness
    @user.name = users(:one).name
    assert !@user.valid?
  end
  
  def test_password_hash_presence    
    @user.password_hash = nil 
    assert !@user.valid?
  end
  
  def test_password_salt_presence    
    @user.password_salt = nil 
    assert !@user.valid?
  end
end
