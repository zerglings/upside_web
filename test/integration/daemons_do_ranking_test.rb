require 'test_helper'

class DaemonsDoRanking < ActionController::IntegrationTest
  fixtures :users, :portfolios
  
  DAILY = PortfolioStat::Frequencies::DAILY
  HOURLY = PortfolioStat::Frequencies::HOURLY
  
  # If this isn't here, Rails runs the entire test in a transaction. This means
  # the ranking daemon doesn't see anything that happens in here :(
  self.use_transactional_fixtures = false

  test "starting up the server does ranking" do
    portfolios(:rich_kid).cash = Portfolio::MAX_CASH
    portfolios(:rich_kid).save!
    
    old_flag_count = WarningFlag.count
    
    Daemonz.with_daemons do
      # Wait 2 seconds for ranking to complete.
      @daily = portfolios(:rich_kid).stats_for DAILY
      daily_old_rank = @daily.rank
      20.times do
        sleep 0.1
        @daily.reload
        break if @daily.rank != daily_old_rank
      end

      assert_equal 1, @daily.rank, 'Daily ranking brings rich_kid on top'
      assert_equal 1, portfolios(:rich_kid).stats_for(HOURLY).rank,
                   'Hourly ranking brings rich_kid on top'
      assert_equal Portfolio::MAX_CASH, @daily.net_worth,
                   'Net worth is clamped'
      assert_operator 1, :<=, WarningFlag.count - old_flag_count,
                      'Net worth clamping creates warning flags'
    end
  end
end
