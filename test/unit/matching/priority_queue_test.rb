require 'test_helper'

class PriorityQueueTest < ActiveSupport::TestCase
  def setup
    @queue = Matching::PriorityQueue.new
  end
  
  def test_sorting
    [5, 1, 4, 2, 8, 7, 9, 6, 3].each { |i| @queue.insert i }
    assert_equal 9, @queue.length, 'Queue length'
    [9, 8, 7, 6, 5, 4, 3, 2, 1].each do |i|
      assert_equal i, @queue.top
      @queue.delete_top
    end
    assert_equal 0, @queue.length, 'Queue length'
    assert_equal nil, @queue.top
  end
  
  def test_deletions_with_insertions
    [5, 1, 4, 2, 8].each { |i| @queue.insert i }
    [8, 5, 4].each do |i|
      assert_equal i, @queue.top
      assert_equal i, @queue.delete_top
    end
    
    [-1, 0, 1.5].each { |i| @queue.insert i }
    
    [2, 1.5, 1, 0, -1].each do |i|
      assert_equal i, @queue.top
      assert_equal i, @queue.delete_top
    end
  end
  
  def test_empty
    assert_equal 0, @queue.length
    assert_equal nil, @queue.top, 'top'
    assert_equal nil, @queue.top_priority, 'top priority'
  end
end