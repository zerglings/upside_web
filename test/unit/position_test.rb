require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  
  def setup
    @position = Position.new(:stock_id => 8, :portfolio_id => 123, 
                              :is_long => true, :quantity => 24, :average_base_cost => 48)
  end
  
  def test_validity
    assert @position.valid?
  end
  
  def test_stock_id_not_null
    @position.stock_id = nil
    assert !@position.valid?
  end
  
  def test_stock_id_positive_number
    @position.stock_id = 0
    assert !@position.valid?
    @position.stock_id = -1
    assert !@position.valid?
  end
    
  def test_portfolio_id_not_null
    @position.portfolio_id = nil
    assert !@position.valid?
  end
  
  def test_portfolio_id_positive_number
    @position.portfolio_id = 0
    assert !@position.valid?
    @position.portfolio_id = -1
    assert !@position.valid?
  end
  
  def test_is_long_not_null
    @position.is_long = nil
    assert !@position.valid?
  end
  
  def test_quantity_not_null
    @position.quantity = nil
    assert !@position.valid?
  end
  
  def test_quantity_positive_number
    @position.quantity = 0
    assert !@position.valid?
    @position.quantity = -1
    assert !@position.valid?
  end
  
  def test_average_base_cost_not_null
    @position.average_base_cost = nil
    assert !@position.valid?
  end
  
  def test_average_base_cost_number
    @position.average_base_cost = ""
    assert !@position.valid?
  end
  
end
