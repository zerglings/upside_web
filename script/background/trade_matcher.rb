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

class TradeMatcher < SimpleDaemon::Base
  SimpleDaemon::WORKING_DIRECTORY = "#{RAILS_ROOT}/log"
  
  def self.start    
    STDOUT.sync = true
    @logger = Logger.new(STDOUT)
    @logger.level = RAILS_ENV =~ /prod/ ? Logger::INFO : Logger::DEBUG
    unless RAILS_ENV =~ /prod/ || RAILS_ENV == 'test'
      # disable SQL logging that would happen every second
      ActiveRecord::Base.logger.level = Logger::INFO
    end
    
    @logger.info "Creating trade matcher"
    
    @controller = Matching::TradeMatchingController.new
        
    @logger.info "Started trade matcher"
    
    loop do 
      # execute tasks
      begin
        @controller.round
        @logger.debug "Completed round" if RAILS_ENV == 'test'
      rescue Exception => e
        @logger.error "Error in matching - #{e.class.name}: #{e}"
        @logger.info e.backtrace.join("\n")
      end

      Kernel.sleep 1
    end
  end
  
  def self.stop
    @logger.info "Stopping trade matcher"
  end
end

TradeMatcher.daemonize
