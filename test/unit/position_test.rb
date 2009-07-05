require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  fixtures :positions, :portfolios, :stocks
  
  def setup
    @position = Position.new :stock_id => 8, :portfolio_id => 123,
                             :is_long => true, :quantity => 24,
                             :average_base_cost => 48
  end
  
  def test_validity
    assert @position.valid?
  end
  
  def test_stock_id_cannot_be_null
    @position.stock_id = nil
    assert !@position.valid?
  end
  
  def test_stock_id_must_be_positive
    @position.stock_id = 0
    assert !@position.valid?
    @position.stock_id = -1
    assert !@position.valid?
  end
    
  def test_portfolio_id_cannot_be_null
    @position.portfolio_id = nil
    assert !@position.valid?
  end
  
  def test_portfolio_id_must_be_positive
    @position.portfolio_id = 0
    assert !@position.valid?
    @position.portfolio_id = -1
    assert !@position.valid?
  end
  
  def test_is_long_cannot_be_null
    @position.is_long = nil
    assert !@position.valid?
  end
  
  def test_quantity_cannot_be_null
    @position.quantity = nil
    assert !@position.valid?
  end
  
  def test_quantity_must_be_positive
    @position.quantity = 0
    assert !@position.valid?
    @position.quantity = -1
    assert !@position.valid?
  end
  
  def test_average_base_cost_cannot_be_null
    @position.average_base_cost = nil
    assert !@position.valid?
  end
  
  def test_average_base_cost_number
    @position.average_base_cost = ""
    assert !@position.valid?
  end
  
  def test_net_worth
    spreads = { stocks(:ms) => { :close => 13.14 },
                stocks(:gs) => { :close => 70.5 } }
    
    assert_equal 13.14 * 5000, positions(:ms_long).net_worth(spreads),
                 'Networth for MS long'
    assert_equal 13.14 * -300, positions(:ms_short).net_worth(spreads),
                 'Networth for MS short'
    assert_equal 70.5 * 200, positions(:gs_long).net_worth(spreads),
                 'Networth for GS long'
    assert_equal 70.5 * -450, positions(:gs_short).net_worth(spreads),
                 'Networth for GS short'
  end
end
