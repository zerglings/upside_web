module ClientCrypto::IphoneFprints  
  # Computes the application finger-print for an iPhone client.
  def self.app_fprint(device_or_hash)    
    fp_dir = ClientCrypto::AppFprints.fprint_data_directory device_or_hash 
    manifest_path = File.join(fp_dir, 'StockPlay')
    return '' unless File.exist? manifest_path
    Imobile.crypto_app_fprint device_or_hash, manifest_path
  end
end
