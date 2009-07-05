require 'test_helper'

class WarningFlagTest < ActiveSupport::TestCase
  fixtures :portfolios, :users
  
  def setup
    super
    @flag = WarningFlag.minor portfolios(:rich_kid), 'Logs on too often'
  end
  
  def test_valid_setup
    assert @flag.valid?
  end
  
  [:severity, :description, :source_file, :source_line, :stack].each do |attr|
    define_method :"test_#{attr}_required" do      
      @flag.send :"#{attr}=", nil      
      assert !@flag.valid?
    end
  end
  
  [[:description, 256], [:source_file, 256]].each do |attr, length|
    define_method :"test_#{attr}_length" do
      @flag.send :"#{attr}=", 'A' * length
      assert @flag.valid?
      @flag.send :"#{attr}=", 'A' * (length + 1)
      assert !@flag.valid?
    end
  end
  
  def test_severity_numericality
    @flag.source_line = 'one'
    assert !@flag.valid?, 'String severity'
    @flag.source_line = 2.71
    assert !@flag.valid?, 'Fractional severity'
    @flag.source_line = -1
    assert !@flag.valid?, 'Negative severity'    
  end
  
  def test_source_line_numericality
    @flag.source_line = 'one'
    assert !@flag.valid?, 'String source line'
    @flag.source_line = 3.14
    assert !@flag.valid?, 'Fractional source line'
    @flag.source_line = 0
    assert !@flag.valid?, 'Non-positive source line'
  end
        
  def test_subject_is_polymorphic
    @flag.subject = users(:rich_kid)
    assert @flag.valid?
    @flag.subject = nil
    assert @flag.valid?
  end
  
  def test_raise
    severity = 1
    description = 'Doing suspiciously well'
    golden_file = './test/unit/warning_flag_test.rb'
    # NOTE: The source line is the line containing the WarningFlag.raise call.
    #       It will likely change as the test gets revised. Sucks.
    golden_line = __LINE__ + 3
    
    assert_difference "WarningFlag.count" do
      WarningFlag.raise portfolios(:rich_kid), severity, description
    end
    flag = WarningFlag.last
    
    assert_equal portfolios(:rich_kid), flag.subject, 'Incorrect portfolio'
    assert_equal description, flag.description, 'Incorrect description'
    assert_equal severity, flag.severity, 'Incorrect severity'
    assert_equal golden_file, flag.source_file, 'Incorrect source file'
    assert_equal golden_line, flag.source_line, 'Incorrect source line'
    assert_equal "#{golden_file}:#{golden_line}:in `test_raise'",
                 flag.stack.first, "Stack trace doesn't look right"                 
  end
end
