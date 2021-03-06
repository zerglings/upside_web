require 'test_helper'

module CommonUserTests  
  def test_setup_valid
    assert @user.valid?
  end
  
  def test_user_name_presence
    @user.name = ""
    assert !@user.valid?
    
    @user.name = nil
    assert !@user.valid?
  end  

  def test_password_confirmation
    @user.password = users(:rich_kid).password_salt
    assert !@user.valid?
  end
  
  def test_password_hash_presence    
    @user.password_hash = nil 
    assert !@user.valid?
  end
  
  def test_user_name_with_spaces
    if @user.pseudo_user
      @user.name = "bu f" + "buffet" * 10
    else
      @user.name = "buf fet"
    end
    assert !@user.valid?
  end
  
  def test_pseudo_user_must_be_set
    @user.pseudo_user = nil
    assert !@user.valid?
  end
    
  def test_default_admin_is_false
    @user.is_admin = nil
    @user.valid?
    assert_equal false, @user.is_admin
  end
  
  def test_is_admin_true_or_false
    @user.is_admin = 'yes'
    assert @user.valid?
    assert_equal false, @user.is_admin
  end  
end

class UserTest < ActiveSupport::TestCase
  fixtures :devices, :portfolios, :users

  include CommonUserTests
  
  def setup
    @user = User.new :name => "buffet",
                     :password => "money",
                     :password_confirmation => "money"
    @user.pseudo_user = false
  end
  
  def test_user_name_length
    @user.name = "buf"
    assert !@user.valid?
    
    @user.name = "buffetbuffetbuffe"
    assert !@user.valid?
  end
        
  def test_user_name_is_m0ney
   @user.name = "m0ney"
   @user.save!
   assert @user.valid?
  end
  
  def test_user_name_uniqueness
    @user.name = users(:rich_kid).name
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
  
  def test_login_correct_user_and_password
    user = User.authenticate(users(:rich_kid).name, 'password' )
    assert user, 'Valid user was not authenticated'
    assert_equal user.id, users(:rich_kid).id, 'Wrong user was authenticated'
  end
  
  def test_login_correct_user_but_wrong_password
    user = User.authenticate(users(:rich_kid).name, 'pass' )
    assert_equal user, nil, 'User was authenticated with wrong password'
  end
  
  def test_login_wrong_user_name
    user = User.authenticate( 'inexistent', 'password')
    assert_equal user, nil, 'Inexistent user was authenticated'
  end
  
  def test_notify_devices_with_zerocast
    assert_equal [], users(:short_lover).notify_devices({'apn' => true})
  end
  
  def test_notify_devices_with_unicast_and_subject
    user = users(:rich_kid)
    subject = portfolios(:rich_kid)
    payload = { 'apn' => { 'alert' => "Today's weather is awesome!" } }
    notifications = user.notify_devices payload, subject
    
    assert_equal 1, notifications.length, 'Expected one notification'
    notification = notifications.first    
    assert_equal ImobilePushNotification, notification.class,
                 'Wrong model created'
    assert_equal payload, notification.payload, 'Wrong payload'
    assert_equal subject, notification.subject, 'Wrong subject'
    assert !notification.new_record?, 'Notification not saved'
  end
  
  def test_notify_devices_with_multicast
    user = users(:admin)
    payload = { 'apn' => { 'alert' => "Today's weather is awesome!" } }
    notifications = user.notify_devices payload
    
    assert_equal 2, notifications.length, 'Admin has 2 devices'
    notifications.each do |notification|
      assert_equal payload, notification.payload, 'Wrong payload'
      assert_equal user, notification.subject, 'Wrong subject'      
      assert !notification.new_record?, 'Notification not saved'
    end
    assert_equal notifications.map { |n| n.device }.sort_by(&:id),
                 [:ipod_touch_2g, :iphone_2g_on_prod].map { |d| devices(d) }.
                 sort_by(&:id), 'Notifications created for the wrong devices'
  end
end

class PseudoUserTest < ActiveSupport::TestCase
  include CommonUserTests
  
  def setup
    @user = User.new :name => "abcde123" * 8,
                     :password => "money",
                     :password_confirmation => "money"
    @user.pseudo_user = true                     
  end
  
  def test_user_name_length
    @user.name = "12345"
    assert !@user.valid?
    
    @user.name = "12345678" * 8
    assert @user.valid?   
  end  
  
  def test_deleting_user_deletes_dependencies
    @user.save!
    @user.destroy
    assert_equal nil, Portfolio.find(:first, 
                                     :conditions => {:user_id => @user.id})
  end
  
  def test_create_user_also_creates_portfolio
    @user.save!
    assert_not_nil Portfolio.find(:first, 
                                  :conditions => {:user_id => @user.id})
    @user.pseudo_user = false
    @user.name = "noob"
    old_count = Portfolio.count
    @user.save!
    assert_equal old_count, Portfolio.count
  ensure 
    @user.destroy
  end
  
  def test_pseudo_user_generation
    device_id = '31415' * 8
    user = User.new_pseudo_user device_id
    assert_equal user.name, 'a5f271f817c04cca75e8e8ae70b2ca1733956aeef8f787de0e3203555db69602'
    assert_equal user.password, device_id
    assert_equal user.is_admin, false
  end  
end
