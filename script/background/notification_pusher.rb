#!/usr/bin/env ruby

# load Rails
RAILS_ENV = ARGV[1] || 'development'
require File.dirname(__FILE__) + '/../../config/environment.rb'

require 'simple-daemon'

# Restore timestamps in the log.
class Logger
  def format_message(severity, timestamp, progname, msg)
    "#{severity[0,1]} [#{timestamp} PID:#{$$}] #{progname}: #{msg}\n"
  end
end

class NotificationPusher < SimpleDaemon::Base
  SimpleDaemon::WORKING_DIRECTORY = "#{RAILS_ROOT}/log"
  
  def self.start    
    STDOUT.sync = true
    @logger = Logger.new(STDOUT)
    @logger.level = RAILS_ENV =~ /prod/ ? Logger::INFO : Logger::DEBUG
    unless RAILS_ENV =~ /prod/ || RAILS_ENV == 'test'
      # Disable SQL logging in debugging.
			# This is handy if your daemon changes the database often.
      ActiveRecord::Base.logger.level = Logger::INFO
    end
		
    @logger.info "Starting daemon #{self.name}"		
        
    @delivery_controller = ImobileEx::NotificationDeliveryController.new
    loop do 
      begin
        # TODO: execute some tasks in the background repeatedly
        
        @delivery_controller.round
      rescue Exception => e
        @logger.error "Error in daemon #{self.name} - #{e.class.name}: #{e}"
        @logger.info e.backtrace.join("\n")
      end

      Kernel.sleep 1
    end
  end
  
  def self.stop
    @logger.info "Stopping daemon #{self.name}"
  end
end

NotificationPusher.daemonize
