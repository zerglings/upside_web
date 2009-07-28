# == Schema Information
# Schema version: 20090728042053
#
# Table name: stock_cache_lines
#
#  id         :integer         not null, primary key
#  ticker     :string(16)      not null
#  info_type  :string(8)       not null
#  value      :string(1024)    not null
#  updated_at :datetime
#

class StockCacheLine < ActiveRecord::Base
  # The ticker symbol for the cache line.
  validates_length_of :ticker, :in => 1..10, :allow_nil => false
  
  # Identifier for the type of information stored in the cache line.
  #
  # Typically, the first letter of each word in the name of the method computing
  # the information.
  #
  # Example: markets_for_tickers caches its responses using 'mft'
  validates_length_of :info_type, :in => 1..8, :allow_nil => false
  
  # It would be nice to have the uniqueness check below, but it would be
  # expensive as hell. 
  validates_uniqueness_of :info_type, :scope => [:ticker]
  
  # The cached value.
  #
  # NOTE: the obvious alternative is to cache the CSV line, and redo the
  #       decoding. Normally, reading the cache requires YAML parsing. In the
  #       alternative, reading would require CSV parsing and Ruby computation.
  #       We assume YAML parsing is faster than CSV parsing + Ruby code. 
  serialize :value
  
  # Retrieves cached stock information for a set of tickers.
  #
  # Returns a hash mapping ticker symbols to the cached values. The hash
  # contains entries for the tickers which exist in the cache and have
  # un-expired cached values.
  def self.cache_fetch(tickers, info_type, expiration = 3.minutes)
    response = {}
    StockCacheLine.find(:all,
        :conditions => ['info_type = ? AND ticker IN (?) AND updated_at > ?',
                        info_type, tickers, Time.now - expiration]).each do |l|
      response[l.ticker] = l.value
    end
    response
  end
  
  # Retrieves stock lines for a set of tickers.
  #
  # Returns a hash mapping ticker symbols to the cache lines. The hash contains
  # entries for the tickers which exist in the cache, even if their cached
  # values are expired.
  def self.lines_for(tickers, info_type)
    StockCacheLine.find(:all, :conditions => {:ticker => tickers,
                                              :info_type => info_type}).
                   index_by(&:ticker)
  end
end
