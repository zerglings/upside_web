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
  #   transaction_size:: (tuning parameter) the number of notifications to batch
  #                      in an APNs "transaction" -- if the APNs communication
  #                      breaks down, these notifications will be retransmitted;
  #                      higher numbers decrease bandwidth, but increase the
  #                      chance that users will get duplicate notifications
  def round(max_step_size = 1000, transaction_size = 50)
    loop do
      notifications = ImobilePushNotification.find :all,
                                                   :limit => max_step_size,
                                                   :include => [:device]
      break if notifications.empty?
      push_notifications notifications, transaction_size
    end
    flush_contexts
  end
  
  def initialize
    @contexts = {}
    [:sandbox, :production].each { |bucket| restore_context bucket }
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
  
  # The server type for a Push Notification.
  #
  # The server type is guessed based on the destination device's provisioning
  # information.
  def notification_server_type(notification)
    return nil unless notification.device.app_push_token
    
    case notification.device.app_provisioning
    when 'D', '?'
      :production
    else
      :sandbox
    end
  end
  
  # Pushes a batch of notifications to Apple's Push Notification servers.
  def push_notifications(notifications, transaction_size)
    pushed_notifications = []
    queues = { :production => [], :sandbox => [] }
    
    notifications.each do |notification|
      server_type = notification_server_type notification
      unless server_type
        notification.destroy
        next
      end
    
      queues[server_type] << notification
      if queues[server_type].length == transaction_size        
        push_notifications_atomic queues[server_type], server_type
        pushed_notifications += queues[server_type]
        queues[server_type] = []
      end
    end
    
    queues.each do |server_type, queue|
      next if queue.empty?
      push_notifications_atomic queue, server_type
      pushed_notifications += queue
    end
    pushed_notifications
  end

  # Pushes a batch of notifications atomically to a single APN server.
  #
  # If there is an error during the batch push, the entire batch is re-pushed.
  def push_notifications_atomic(notifications, server_type)
    2.downto(0) do |attempt|
      begin
        return push_notifications_atomic!(notifications, @contexts[server_type])
      rescue
        restore_context server_type
        raise if attempt == 0
      end
    end
  end
  
  # Pushes a batch of notifications to a single APN server.
  #
  # This method doesn't handle exceptions.
  def push_notifications_atomic!(notifications, context)
    notifications.each do |notification|
      push_notification! notification, context
    end
    context.flush
    ImobilePushNotification.destroy notifications
  end

  # Pushes a single notificatin to Apple's Push Notifiation servers.
  def push_notification!(notification, context)
    hex_push_token = notification.device.app_push_token
    payload = notification.payload    
    payload[:push_token] = Imobile.pack_hex_push_token hex_push_token
    context.push payload
  end
  
  # Re-creates a context for an Apple Push Notification server.
  #
  # Called on initialization, and if exceptions are raised during pushing. 
  def restore_context(server_type)
    if @contexts[server_type]
      @contexts[server_type].close rescue nil
    end
    @contexts[server_type] = create_apns_context server_type
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
