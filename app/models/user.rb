require 'digest/sha2'

class User < ActiveRecord::Base
  has_many :devices
  
  # user name
  validates_length_of :name, :in => 4..16,
                      :unless => Proc.new{ |u| u.pseudo_user? },
                      :message => "The user name should have between 4 and 16 characters.",
                      :allow_nil => false
  validates_length_of :name, :is => 40,
                      :if => Proc.new{ |u| u.pseudo_user? },
                      :message => "The user name should be 40 characters.",
                      :allow_nil => false
  validates_format_of :name,
                      :with => /^[^\s]+$/
  validates_uniqueness_of :name                    
  
  # password confirmation
  validates_confirmation_of :password
  
  # SHA-256 of password_salt + user's password
  validates_presence_of :password_hash
  
  # random salt to prevent match attacks on the password db
  validates_presence_of :password_salt
  
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
    (0...4).map { rand(256) }.pack 'C*'
  end
  
  # computes a hash from a password and a salt
  def self.hash_password(password, salt)
    Digest::SHA256.hexdigest salt + password
  end  
end
