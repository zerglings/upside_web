#!/usr/bin/env ruby

# Load Rails.
RAILS_ENV = ARGV[1] || 'development'
require File.dirname(__FILE__) + '/../../config/environment.rb'

# More setup.


# Restore timestamps in the log.
class Logger
  def format_message(severity, timestamp, progname, msg)
    "#{severity[0,1]} [#{timestamp} PID:#{$$}] #{progname}: #{msg}\n"
  end
end

require 'simple-daemon'
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
    
    @matching_controller = Matching::TradeMatchingController.new
    @ranking_controller = BookKeeping::RankingController.new
        
    @logger.info "Started trade matcher"
    
    loop do 
      # execute tasks
      begin
        @matching_controller.round
        @logger.debug "Completed round" if RAILS_ENV == 'test'
      rescue Exception => e
        # This gets thrown when we need to get out.
        break if e.kind_of? SystemExit
        
        @logger.error "Error in matching - #{e.class.name}: #{e}"
        @logger.info e.backtrace.join("\n")
        
        # If something bad happened, it usually makes sense to wait for some
        # time, so any external issues can settle.
        Kernel.sleep 5        
      end
      
      # NOTE: these controllers are executed in the same loop to get consistency
      #       for free. No trades will be executed during ranking, so the
      #       portfolios content are constant while the ranking controller runs.
      #       We'll have to figure out synchronization when we'll need to shard
      #       out matching.
      begin
        @ranking_controller.round
        @logger.debug "Completed round" if RAILS_ENV == 'test'

        Kernel.sleep 1
      rescue Exception => e
        # This gets thrown when we need to get out.
        break if e.kind_of? SystemExit
        
        @logger.error "Error in ranking - #{e.class.name}: #{e}"
        @logger.info e.backtrace.join("\n")

        # If something bad happened, it usually makes sense to wait for some
        # time, so any external issues can settle.
        Kernel.sleep 5
      end
    end
  end
  
  def self.stop
    @logger.info "Stopping trade matcher"
  end
end

TradeMatcher.daemonize
