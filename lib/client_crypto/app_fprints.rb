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
end
