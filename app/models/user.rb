class User < ActiveRecord::Base
  has_many :devices
  
  # user name
  validates_uniqueness_of :name
  validates_length_of :name, :in => 4..16,
                      :message => "The user name should have between 4 and 16 characters.",
                      :allow_nil => false
  validates_format_of :name,
                      :with => /^[^\s]$/
  
  # SHA-256 of password_salt + user's password
  validates_presence_of :password_hash
  
  # random salt to prevent match attacks on the password db
  validates_presence_of :password_salt
end
