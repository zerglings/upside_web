class ImobileEx::NotificationDeliveryController
  Context = Imobile::PushNotificationsContext
  PushNotifications = Imobile::PushNotifications

  # Attempts to deliver all the push notifications in the database.
  #
  # Args:
  #   max_step_size:: (tuning parameter) the number of notifications to read
  #                   from the database at once; increasing this makes the
  #                   process less taxing on the database, but also increases
  #                   memory usage
  def round(max_step_size = 1000)
    loop do
      notifications = ImobilePushNotification.find :all,
                                                   :limit => max_step_size,
                                                   :include => [:device]
      break if notifications.empty?
      push_notifications notifications      
    end
    flush_contexts
  end
  
  def initialize
    @contexts = {}
    restore_contexts
  end  
  
  # The path to the APNs push certificate.
  def apns_certificate_path(server_type)
    case server_type
    when :sandbox
      File.join RAILS_ROOT, 'config', 'imobile', 'apns_development.p12' 
    when :production
      File.join RAILS_ROOT, 'config', 'imobile', 'apns_production.p12'       
    else
      raise "Unknown server type #{server_type}"
    end
  end
  
  # The context (connection to APNs) for a Push Notification.
  #
  # The context is guessed based on the destination device's provisioning
  # information
  def context_for_notification(notification)
    return nil unless notification.device.app_push_token
    
    case notification.device.app_provisioning
    when 'D', '?'
      @contexts[:production]
    else
      @contexts[:sandbox]
    end
  end
  
  # Pushes a batch of notifications to Apple's Push Notification servers.
  def push_notifications(notifications)
    restored_contexts = false
    loop do
      begin
        return push_notifications!(notifications)
      rescue
        raise if restored_contexts
        restore_contexts
        restored_contexts = true
      end
    end    
  end
  
  # Pushes a batch of notifications to Apple's Push Notification servers.
  #
  # This method doesn't handle exceptions.
  def push_notifications!(notifications)
    until notifications.empty?
      notification = notifications.last
      push_notification! notification
      notifications.pop
    end
  end

  # Pushes a single notificatin to Apple's Push Notifiation servers.
  def push_notification!(notification)
    unless context = context_for_notification(notification)
      notification.destroy
      return
    end
    hex_push_token = notification.device.app_push_token
    payload = notification.payload    
    payload[:push_token] = Imobile.pack_hex_push_token hex_push_token
    context.push payload
    notification.destroy
  end
  
  # Re-creates Push Notifications contexts for Apple's servers.
  #
  # This is called if exceptions are raised during pushing. 
  def restore_contexts
    [:production, :sandbox].each do |server_type|
      if @contexts[server_type]
        @contexts[server_type].flush
        @contexts[server_type].close
      end
      @contexts[server_type] = create_apns_context server_type
    end
  end  
  
  # Establishes a new Push Notification context for one of Apple's servers.
  def create_apns_context(server_type)
    Context.new apns_certificate_path(server_type)
  end
  
  def flush_contexts
    @contexts.each do |server_type, context|
      context.flush
    end
  end
end
