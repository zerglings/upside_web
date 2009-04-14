class BookKeeping::RankingController
  # Compute stock spreads for all the stocks in portfolios.
  #
  # Returns a Hash mapping stocks to spreads.
  def stock_spreads
    stocks = Stock.all_in_positions
    spreads = YahooFetcher.spreads_for_tickers stocks.map(&:ticker)
    stock_spreads = {}
    stocks.each_with_index { |stock, i| stock_spreads[stock] = spreads[i] }
    stock_spreads
  end
  

  # Updates the net worths in PortfolioStats for all the portfolios.
  def update_net_worths(frequency)
    spreads = stock_spreads
    Portfolio.find_each do |portfolio|
      stat = portfolio.stats_for frequency
      stat.net_worth = portfolio.net_worth spreads
      stat.save!
    end
    record_stats_update frequency
  end
  
  # Updates the ranks in PortfolioStats based on the networths.
  def update_ranks(frequency)
    PortfolioStat.all(:conditions => { :frequency => frequency },
                      :order => 'net_worth DESC').each_with_index do |stat, i|
      stat.update_attributes! :rank => i + 1
    end
    record_stats_update frequency    
  end

  # Copies portfolio stats from a frequency to another frequency.
  #
  # Presumably, the stats are copied from a faster frequency (e.g. hourly) to
  # a slower frequency (e.g. daily).
  def copy_stats(from_frequency, to_frequency)
    options = { :conditions => { :frequency => from_frequency },
                :include => :portfolio }

    # NOTE: find_each / find_in_batches seem to mess up other finds on the same
    #       model while they're running; can't use here
    PortfolioStat.all(options).each do |from_stat|
      to_stat = from_stat.portfolio.stats_for to_frequency
      to_stat.update_attributes :net_worth => from_stat.net_worth,
                                :rank => from_stat.rank
      to_stat.save!
    end    
    record_stats_update to_frequency
  end
  
  # Records the fact that a portfolio stats update has occurred. 
  def record_stats_update(frequency, timestamp = Time.now)
    ConfigVariable[["updated.portfolio.stats", frequency]] = timestamp
  end
  
  # Returns true if the hourly stats need to be updated.  
  def hourly_update_needed
    last_update = ConfigVariable[["updated.portfolio.stats",
                                  PortfolioStat::Frequencies::HOURLY]]
    !last_update || (Time.now - last_update >= 1.hour)
  end
  
  # Returns true if the daily stats need to be updated.
  def daily_update_needed
    last_update = ConfigVariable[["updated.portfolio.stats",
                                  PortfolioStat::Frequencies::DAILY]]
    !last_update || (Time.now - last_update >= 1.day)
  end
  
  # Perform a full round of the ranking update process.
  def round
    if hourly_update_needed
      hourly = PortfolioStat::Frequencies::HOURLY
      update_net_worths hourly
      update_ranks hourly
    end
    if daily_update_needed
      copy_stats PortfolioStat::Frequencies::HOURLY,
                 PortfolioStat::Frequencies::DAILY 
    end
  end  
end
