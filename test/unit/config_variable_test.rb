require 'test_helper'

class ConfigVariableTest < ActiveSupport::TestCase
  def setup
    @test_root = config_variables :testing_var_root
    @test_extra = config_variables :testing_var_extra
    @var = ConfigVariable.new :name => @test_root.name, :instance => 2,
                              :value => [3, 4, {:awesome => true }]
  end
  
  def test_setup_valid
    assert @var.valid?
  end  
  
  def test_name_is_required
    @var.name = nil
    assert !@var.valid?
  end

  def test_name_length
    @var.name = ''
    assert !@var.valid?
    
    @var.name = 'x' * 65
    assert !@var.valid?
  end

  def test_instance_is_required
    @var.instance = nil
    assert !@var.valid?
  end
  
  def test_instance_must_be_integer
    @var.instance = 'z'
    assert !@var.valid?
    
    @var.instance = 3.5
    assert !@var.valid?
  end
  
  def test_instance_must_be_positive
    @var.instance = -5
    assert !@var.valid?
  end
  
  def test_name_and_instance_uniqueness
    @var.name, @var.instance = @test_root.name, @test_root.instance
    assert !@var.valid?
  end
  
  def test_retrieval
    assert_equal 'Awesomeness', ConfigVariable[@test_root.name],
                 'Fetch root by name'
    assert_equal 'Awesomeness', ConfigVariable[[@test_root.name, 0]],
                 'Fetch root by name and instance'
    assert_equal({:one => 'one', :two=> [3, 4] },
                 ConfigVariable[[@test_root.name, 1]],
                 'Fetch #1 by name and instance')
  end
  
  def test_storing
    complex_value = [:extra, :values, {:here => false}]
    ConfigVariable[@test_root.name] = complex_value
    assert_equal complex_value, ConfigVariable[@test_root.name],
                 'Store complex value into root by name'
    
    complex_value[2][:here] = true
    ConfigVariable[[@test_root.name, 0]] = complex_value
    assert_equal complex_value, ConfigVariable[@test_root.name],
                 'Store complex value into root by name and instance'
                 
    simple_value = 'awesomeness_x2'
    ConfigVariable[[@test_extra.name, @test_extra.instance]] = simple_value
    assert_equal simple_value,
                 ConfigVariable[[@test_extra.name, @test_extra.instance]],
                 'Store simple value into #1 by name and instance'    
    assert_equal complex_value, ConfigVariable[@test_root.name],
                 'Storing simple value into #1 changed root'
  end
end
