require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  
  def setup
    @position = Position.new(:stock_id => 8, :portfolio_id => 123, 
                              :is_long => true, :quantity => 24, :average_base_cost => 48)
  end
  
  def test_position_validity
    assert @position.valid?
  end
  
  def test_position_stock_id_presence
    @position.stock_id = nil
    assert !@position.valid?
  end
  
  def test_position_stock_id_numericality
    @position.stock_id = 0
    assert !@position.valid?
    @position.stock_id = -1
    assert !@position.valid?
  end
    
  def test_position_portfolio_id_presence
    @position.portfolio_id = nil
    assert !@position.valid?
  end
  
  def test_position_portfolio_id_numericality
    @position.portfolio_id = 0
    assert !@position.valid?
    @position.portfolio_id = -1
    assert !@position.valid?
  end
  
  def test_position_is_long_presence
    @position.quantity = nil
    assert !@position.valid?
  end
  
  def test_position_quantity_numericality
    @position.quantity = 0
    assert !@position.valid?
    @position.quantity = -1
    assert !@position.valid?
  end
  
  def test_position_average_base_cost_numericality
    @position.average_base_cost = ""
    assert !@position.valid?
  end
  
end
