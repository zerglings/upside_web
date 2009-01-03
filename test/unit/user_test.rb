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
  
  def test_salt_randomness
    num_salts = 1024
    salts = (0...num_salts).map { User.random_salt }
    assert_equal num_salts, salts.uniq.length 
  end
  
  def test_different_passwords_have_different_hashes
    num_passwords = 1024
    salt = '1234'
    password_base = 'prefix_'
    passwords = (0...num_passwords).map { |i| password_base + i.to_s }
    hashes = passwords.map { |p| User.hash_password p, salt }
    assert_equal num_passwords, hashes.uniq.length
  end
  
  def test_different_salts_have_different_hashes
    num_salts = 1024
    password = 'secret_password'
    salts = (0...num_salts).map { |i| [i].pack('N') }
    hashes = salts.map { |s| User.hash_password password, s }
    assert_equal num_salts, hashes.uniq.length
  end
end
