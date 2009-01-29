require 'digest/sha2'

# Authentication for the iPhone application.
module IphoneAuthFilters
  def self.signature(device_id)
    # The only bits protecting from widespread piracy of our service.
    # Treat accordingly.
    secret = "\245\023\240\237\324\362\311\021:C\232\243LI\"m"
    Digest::SHA2.hexdigest device_id + secret
  end
  
  def self.signature_version
    "1"
  end
  
  # Validates a device-generated signature.
  def self.is_good_signature(device_id, sig, sig_version)
    case sig_version
    when '1'
      return sig == self.signature(device_id)
    else
      return false
    end
  end
  
  # Ensures that the request originates from a device with our secret key on it.
  # Sets @s_unique_id on success, aborts request processing if the request does
  # not meet the requirements. 
  def ensure_iphone_request
    @s_unique_device_id = params[:unique_id]
    if @s_unique_device_id and params[:device_sig] and params[:device_sig_v]
      return true if IphoneAuthFilters.is_good_signature @s_unique_device_id,
                                                         params[:device_sig],
                                                         params[:device_sig_v]      
    end
    respond_to do |format|
      format.html { redirect_to :controller => :sessions, :action => :new }
      format.xml do
        render :xml => { :error => { :message => 'Invalid device signature.',
                                     :reason => :device_auth } }
      end
    end
    return false
  end
end
