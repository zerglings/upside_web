require 'test_helper'

class PortfolioTest < ActiveSupport::TestCase

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
end
