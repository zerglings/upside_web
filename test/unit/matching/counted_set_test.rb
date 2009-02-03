require 'test_helper'

class CountedSetTest < ActiveSupport::TestCase
  def setup
    @set = Matching::CountedSet.new
  end
  
  def test_adds
    [1, 2, 3, 4, 3, 2, 1, 2].each { |i| @set << i }
    assert_equal @set.to_a.sort, [1, 2, 3, 4]
  end
  
  def test_adds_and_deletes
    [1, 2, 3, 4, 3, 2, 1, 2].each { |i| @set << i }
    assert_equal @set.to_a.sort, [1, 2, 3, 4]
    [2, 1, 2].each { |i| @set.delete i }
    assert_equal @set.to_a.sort, [1, 2, 3, 4]
    [3, 4].each { |i| @set.delete i }
    assert_equal @set.to_a.sort, [1, 2, 3]
    [3, 4, 2].each { |i| @set.delete i }
    assert_equal @set.to_a.sort, [1]
    [1].each { |i| @set.delete i }
    assert_equal @set.to_a.sort, []
  end
end