require 'test_helper'

class StockInfoTest < ActiveSupport::TestCase
  fixtures :stocks, :stock_infos

  def setup
    @stock_info = StockInfo.new :stock_id => 3,
                                :company_name => "zergling.net"
  end
  
  def test_validity
    assert @stock_info.valid?
  end
  
  def test_stock_id_cannot_be_null
    @stock_info.stock_id = nil
    assert !@stock_info.valid?
  end
  
  def test_stock_id_must_be_positive
    @stock_info.stock_id = 0
    assert !@stock_info.valid?
    @stock_info.stock_id = -1
    assert !@stock_info.valid?
  end
  
  def test_stock_id_uniqueness
    @stock_info.stock_id = stocks(:gs).id
    assert !@stock_info.valid?
  end
  
  def test_company_name_cannot_be_null
    @stock_info.company_name = nil
    assert !@stock_info.valid?
  end
  
  def test_company_name_length
    @stock_info.company_name = ""
    assert !@stock_info.valid?
    @stock_info.company_name = "01234567890" * 10 + "1"
    assert !@stock_info.valid?
  end
  
end
