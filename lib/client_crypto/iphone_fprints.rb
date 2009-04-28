module ClientCrypto::IphoneFprints
  # Extracts the attributes involved in device finger-printing from a Device.
  def self.device_attributes(device)
    attrs = {}
    [:app_version, :hardware_model, :os_name, :os_version,
     :unique_id].each do |sym|
      attrs[sym.to_s] = device.send sym
    end
    attrs
  end
  
  # Computes the application finger-print for an iPhone client.
  def self.app_fprint(device_or_hash)
    if device_or_hash.kind_of? Device
      device_attributes = self.device_attributes device_or_hash
    else
      device_attributes = device_or_hash
    end
    
    fp_dir = ClientCrypto::AppFprints.fprint_data_directory device_attributes 
    manifest_path = File.join(fp_dir, 'Info.plist')
    return '' unless File.exist? manifest_path
    manifest = File.read manifest_path
    key = ClientCrypto::AppFprints.device_fprint device_attributes
    iv = "\0" * 16
    ClientCrypto::AppFprints.file_data_fprint manifest, key, iv
  end
end
