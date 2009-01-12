require 'test_helper'

class PortfolioTest < ActiveSupport::TestCase

  def setup
    @portfolio = Portfolio.new(:cash => portfolios(:one).cash, :user_id => 35)
  end
  
  def test_setup_valid
    assert @portfolio.valid?
  end
  
  def test_unique_user_id
    @portfolio.user_id = portfolios(:two).user_id
    assert !@portfolio.valid?
  end
  
  def test_user_id_presence
    @portfolio.user_id = nil
    assert !@portfolio.valid?
  end
  
  def test_cash_balance_presence
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
  
  def test_portfolio_dependent_on_user
    user = User.new(:name => 'angry',
                    :password => 'blah',
                    :password_confirmation => 'blah',
                    :pseudo_user => false) 
    user.save!
    portfolio = Portfolio.new(:user_id => user.id, :cash => 40)
    portfolio.save!
    user.destroy
    assert_equal nil, Portfolio.find(:first, 
                                     :conditions => {:user_id => user.id})
  end
end
