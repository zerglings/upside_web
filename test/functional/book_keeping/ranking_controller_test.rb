require 'test_helper'
require 'flexmock/test_unit'

class RankingControllerTest < ActionController::IntegrationTest
  # This really is a functional test, but the controller it's testing does not
  # inherit from ActionController::Base

  fixtures :all
  HOURLY = PortfolioStat::Frequencies::HOURLY
  DAILY = PortfolioStat::Frequencies::DAILY
  
  def setup
    super
    @controller = BookKeeping::RankingController.new
    @rich_kid = portfolios :rich_kid
    @device_user = portfolios :device_user
  end
  
  # Mocks the Yahoo spread fetcher. Returns the mocked spreads. 
  def mock_yahoo_spreads
    mock_spreads = [{ :close => 70.5 }, { :close => 13.14 }]
    flexmock(YahooFetcher).should_receive(:spreads_for_tickers).
                           with(['GS', 'MS']).and_return(mock_spreads)
    { stocks(:ms) => { :close => 13.14 }, stocks(:gs) => { :close => 70.5 } }
  end
    
  def test_stock_spreads
    golden_spreads = mock_yahoo_spreads 
    assert_equal golden_spreads, @controller.stock_spreads
  end
  
  def test_update_net_worths
    old_daily_net_worth = portfolio_stats(:rich_kid_daily).net_worth
    mock_yahoo_spreads
    @controller.update_net_worths HOURLY
    flexmock(@controller).should_receive(:record_stats_update).with(HOURLY)
    
    # stolen from PortfolioTest#test_net_worth
    assert_equal 10_044_133.0, @rich_kid.stats_for(HOURLY).net_worth,
                 "rich_kid's hourly net worth incorrectly updated"
    
    assert_equal old_daily_net_worth,
                 @rich_kid.stats_for(DAILY).reload.net_worth,
                 "Daily net worth was changed and it shouldn't have"
    assert_equal @device_user.cash,
                 @device_user.stats_for(HOURLY).reload.net_worth,
                 "device_user's hourly net worth should be its cash balance"   
  end
  
  def test_update_ranks
    mock_yahoo_spreads
    flexmock(@controller).should_receive(:record_stats_update).
                          with(HOURLY).twice
    @controller.update_net_worths HOURLY
    @controller.update_ranks HOURLY
    
    assert_equal 1, @rich_kid.stats_for(HOURLY).rank
    
    portfolio_syms = [:match_buyer, :match_seller, :admin].sort_by do |sym|
      [-portfolios(sym).cash, -portfolios(sym).id]
    end
    assert_equal [2, 3, 6], portfolio_syms.map { |sym|
      portfolios(sym).stats_for(HOURLY).rank }
  end
  
  def test_copy_stats    
    hourly = portfolio_stats(:rich_kid_hourly)
    flexmock(@controller).should_receive(:record_stats_update).with(DAILY)
    @controller.copy_stats HOURLY, DAILY
    
    daily = portfolio_stats(:rich_kid_daily).reload
    assert_equal hourly.net_worth, daily.net_worth, 'Networth not copied'
    assert_equal hourly.rank, daily.rank, 'Rank not copied'
  end
  
  def test_hourly_update_needed
    assert @controller.hourly_update_needed, 'No update done ever'
    
    @controller.record_stats_update HOURLY
    assert !@controller.hourly_update_needed, 'Hourly update just done'
    
    @controller.record_stats_update HOURLY, (Time.now - 1.hour - 1)
    assert @controller.hourly_update_needed, 'Time faked to one hour behind'    
  end
  
  def test_daily_update_needed
    assert @controller.daily_update_needed, 'No update done ever'

    @controller.record_stats_update DAILY
    assert !@controller.daily_update_needed, 'Daily update just done'

    @controller.record_stats_update DAILY, (Time.now - 1.day - 1)
    assert @controller.daily_update_needed, 'Time faked to one day behind'    
  end
  
  [[false, false], [false, true], [true, false], [true, true]].each do |updates|
    test "round hourly #{updates.first} daily #{updates.last}" do
      flexmock(@controller).should_receive(:hourly_update_needed).
                            and_return(updates.first)
      flexmock(@controller).should_receive(:daily_update_needed).
                            and_return(updates.last)

      @controller.round
      golden_hourly = updates.first ? 1 : 3
      golden_daily = updates.last ? golden_hourly : 5
      assert_equal golden_hourly, @rich_kid.stats_for(HOURLY).rank,
                   "Hourly rank update"
      assert_equal golden_daily, @rich_kid.stats_for(DAILY).rank,
                   "Daily rank update"
    end
  end  
end
