require 'test_helper'

class PortfolioTest < ActiveSupport::TestCase
  fixtures :portfolios, :positions, :stocks

  def setup
    @portfolio = Portfolio.new :cash => portfolios(:rich_kid).cash,
                               :user_id => 35
  end
  
  def test_setup_valid
    assert @portfolio.valid?
  end
  
  def test_unique_user_id
    @portfolio.user_id = portfolios(:device_user).user_id
    assert !@portfolio.valid?
  end
  
  def test_user_id_cannot_be_nil
    @portfolio.user_id = nil
    assert !@portfolio.valid?
  end
  
  def test_cash_balance_cannot_be_nil
     @portfolio.cash = nil
     assert !@portfolio.valid?
  end
  
  def test_cash_balance_too_small
    @portfolio.cash = -(Portfolio::MAX_CASH + 0.01)
    assert !@portfolio.valid?
  end
  
  def test_cash_balance_too_large
    @portfolio.cash = (Portfolio::MAX_CASH + 0.01)
    assert !@portfolio.valid?
  end
  
  def test_cash_balance_scale
    @portfolio.cash = 9.999
    assert !@portfolio.valid?
  end
  
  def test_cash_balance_starts_at_quarter_million
    newport = Portfolio.new
    assert_equal Portfolio::NEW_PLAYER_CASH, newport.cash
  end
  
  def test_clamp_cash
    assert_difference 'WarningFlag.count', 0 do
      @portfolio.clamp_cash
    end
    
    @portfolio.cash = -Portfolio::MAX_CASH - 10
    assert_difference 'WarningFlag.count', 1, 'Cash below minimum' do
      @portfolio.clamp_cash
    end
    assert_equal -Portfolio::MAX_CASH, @portfolio.cash, 'Cash below minimum'
  
    @portfolio.cash = Portfolio::MAX_CASH + 10
    assert_difference 'WarningFlag.count', 1, 'Cash above maximum' do
      @portfolio.clamp_cash
    end
    assert_equal Portfolio::MAX_CASH, @portfolio.cash, 'Cash above maximum'
  end
  
  def test_net_worth
    spreads = { stocks(:ms) => { :close => 13.14 },
                stocks(:gs) => { :close => 70.5 } }
    
    # 10_000_000 + 13.14 * (5000 - 300) + 70.5 * (200 - 450)
    assert_equal 10_044_133.0, portfolios(:rich_kid).net_worth(spreads),
                 'Networth for rich_kid'
  end
end
