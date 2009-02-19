# == Schema Information
# Schema version: 20090120032718
#
# Table name: users
#
#  id            :integer         not null, primary key
#  name          :string(64)      not null
#  password_hash :string(64)      not null
#  password_salt :string(4)       not null
#  pseudo_user   :boolean         default(TRUE), not null
#  is_admin      :boolean         not null
#  created_at    :datetime
#  updated_at    :datetime
#

require 'digest/sha2'

class User < ActiveRecord::Base
  before_validation_on_create :set_admin_false
  
  has_many :devices
  has_one :portfolio, :dependent => :destroy
  
  # protect from mass assignment 
  attr_protected :is_admin, :pseudo_user
  
  # create a portfolio for user after user is created
  after_create do |user|
    portfolio = Portfolio.new(:user => user)
    portfolio.save!  
  end
    
  # password confirmation
  validates_confirmation_of :password
  
  # SHA-256 of password_salt + user's password
  validates_presence_of :password_hash
  
  # random salt to prevent match attacks on the password db
  validates_presence_of :password_salt
  
  # user name
  validates_length_of :name, :in => 4..16,
                      :unless => Proc.new{ |u| u.pseudo_user? },
                      :message => "The user name should have between 4 and 16 characters.",
                      :allow_nil => false
  validates_length_of :name, :is => 64,
                      :if => Proc.new{ |u| u.pseudo_user? },
                      :message => "Pseudo-user names should be 64 characters.",
                      :allow_nil => false
  validates_format_of :name,
                      :with => /^[^\s]+$/,
                      :message => "User names cannot contain spaces.",
                      :allow_nil => false
  validates_uniqueness_of :name, :allow_nil => false

  # True for users automatically created by devices. These accounts have
  # auto-generated names and passwords, and cannot be used from the Web or other
  # devices.
  validates_inclusion_of :pseudo_user, :in => [true, false], :allow_nil => false
  
  # admin status
  validates_inclusion_of :is_admin,
                         :in => [true, false],
                         :allow_nil => false,
                         :message => "is_admin must be specified"
  
  attr_accessor :password_confirmation
  attr_reader :password
  
  def self.authenticate(name, password)
    user = self.find_by_name(name)
    if user
      expected_password = hash_password(password, user.password_salt)
      if user.password_hash != expected_password
        user = nil
      end
    end
    user
  end
  
  def password=(new_password)
    @password = new_password
    
    self.password_salt = User.random_salt
    self.password_hash = User.hash_password new_password, password_salt
  end  
  
  # generates a random password salt
  def self.random_salt
    (0...4).map { 32 + rand(64) }.pack 'C*'
  end
  
  # computes a hash from a password and a salt
  def self.hash_password(password, salt)
    Digest::SHA256.hexdigest salt + password
  end  
  
  def self.new_pseudo_user(device_id)
     user = self.new
     user.name = Digest::SHA2.hexdigest device_id
     user.password = device_id
     return user
  end 
 
  protected 
 
  def set_admin_false
    self.is_admin = (name == 'admin') if is_admin.nil?
    true
  end
end
