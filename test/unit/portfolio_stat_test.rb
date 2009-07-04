require 'test_helper'

class PortfolioStatTest < ActiveSupport::TestCase
  fixtures :portfolio_stats, :portfolios
  
  def setup
    @rich_kid = portfolios :rich_kid
    @daily = portfolio_stats :rich_kid_daily
    @hourly = portfolio_stats :rich_kid_hourly
    @admin = portfolios :admin
    
    @stat = PortfolioStat.new :rank => @daily.rank,
                              :net_worth => @daily.net_worth,
                              :portfolio => @admin,
                              :frequency => @daily.frequency
  end
  
  def test_setup_valid
    assert @stat.valid?
  end
  
  def test_portfolio_cannot_be_nil
    @stat.portfolio = nil
    assert !@stat.valid?
  end
  
  def test_portfolio_and_frequency_uniqueness
    @stat.portfolio = @rich_kid
    assert !@stat.valid?
  end
  
  def test_rank_should_be_integer
    @stat.rank = 3.14
    assert !@stat.valid?
    
    @stat.rank = 'boo'
    assert !@stat.valid?
  end
  
  def test_rank_can_be_nil
    @stat.rank = nil
    assert @stat.valid?
  end
  
  def test_net_worth_should_be_number
    @stat.net_worth = 'boo'
    assert !@stat.valid?
  end
  
  def test_net_worth_lower_bound
    @stat.net_worth = -Portfolio::MAX_CASH - 0.01;
    assert !@stat.valid?
  end
  
  def test_net_worth_upper_bound
    @stat.net_worth = Portfolio::MAX_CASH + 0.01
    assert !@stat.valid?
  end
  
  def test_net_worth_scale
    @stat.net_worth = 3.141
    assert !@stat.valid?
    
    @stat.net_worth = BigDecimal.new("1234567890123.45")
    assert @stat.valid?, 'BigDecimal with 2 precision digits'
    @stat.net_worth = BigDecimal.new("1234567890123.4567")
    assert !@stat.valid?, 'BigDecimal with 4 precision digits'

    @stat.net_worth = BigDecimal.new("-1234567890123.45")
    assert @stat.valid?, 'Negative BigDecimal with 2 precision digits'
    @stat.net_worth = BigDecimal.new("-1234567890123.4567")
    assert !@stat.valid?, 'Negative BigDecimal with 4 precision digits'
  end
  
  def test_frequency_string
    assert_equal 'daily', @daily.frequency_string
    assert_equal 'hourly', @hourly.frequency_string
  end
  
  def test_for
    assert_equal @daily, PortfolioStat.for(@rich_kid,
                                           PortfolioStat::Frequencies::DAILY),
                 'Daily stats for rich_kid'
    assert_equal @hourly, PortfolioStat.for(@rich_kid,
                                           PortfolioStat::Frequencies::HOURLY),
                 'Daily stats for rich_kid'

    device_daily = PortfolioStat.for @admin, PortfolioStat::Frequencies::DAILY
    assert device_daily.new_record?, "Daily stats for admin aren't new"
    assert_equal @admin, device_daily.portfolio, 'Wrong portfolio on new stats'
    assert_equal PortfolioStat::Frequencies::DAILY, device_daily.frequency,
                 'Wrong frequency on new stats'
    assert_nil device_daily.rank,
               'Stats created by PortfolioStat.for should not contain a rank'
  end
  
  # TODO(overmind): the code below is replicated from PortfolioTest; clean up 
  
  def test_clamp_net_worth
    assert_difference 'WarningFlag.count', 0 do
      @stat.clamp_net_worth
    end
    
    @stat.net_worth = -Portfolio::MAX_CASH - 10
    assert_difference 'WarningFlag.count', 1, 'Net worth below minimum' do
      @stat.clamp_net_worth
    end
    assert_equal -Portfolio::MAX_CASH, @stat.net_worth,
                 'Net worth below minimum'
  
    @stat.net_worth = Portfolio::MAX_CASH + 10
    assert_difference 'WarningFlag.count', 1, 'Net worth above maximum' do
      @stat.clamp_net_worth
    end
    assert_equal Portfolio::MAX_CASH, @stat.net_worth, 'Net worth above maximum'
  end  
end
