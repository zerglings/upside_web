require 'digest/md5'
require 'digest/sha2'
require 'openssl'

module ClientCrypto::AppFprints
  # The finger-print directory for an OS. 
  def self.os_directory(os_name)
    return os_name.downcase.gsub(' ', '_')
  end
  
  # An app's finger-print directory, derived from device attributes.
  def self.fprint_data_directory(device_attributes)
    os_dir = self.os_directory device_attributes['os_name']
    version_dir = device_attributes['app_version']
    
    File.join RAILS_ROOT, 'client_fprint', os_dir, version_dir
  end
  
  # The finger-print for a set of device attributes.
  #  
  # Copied from ZergSupport's test suite.
  #
  # The finger-print is returned in raw format, to be used as an intermediate
  # product to further processing.
  def self.device_fprint(device_attributes)
    fprint_data = 'D|' +
        device_attributes.keys.sort.map { |k| device_attributes[k] }.join('|')
    Digest::MD5.digest fprint_data 
  end
  
  # The finger-print for a file.
  #
  # This implements ZergSupport's file finger-printing computation.
  #
  # The returned finger-print is hex-formatted, ready for consumption.
  def self.file_data_fprint(data, key, iv = "\0" * 16)
    cipher = OpenSSL::Cipher::Cipher.new 'aes-128-cbc'
    cipher.encrypt
    cipher.key, cipher.iv = key, iv
    
    plain = data + "\0" * ((16 - (data.length & 0x0f)) & 0x0f)
    crypted = cipher.update plain
    Digest::SHA2.hexdigest crypted
  end
end
