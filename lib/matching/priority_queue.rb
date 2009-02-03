require 'rbtree'

# An efficient max-priority queue.
class Matching::PriorityQueue
  def initialize
    @queue = RBTree.new
  end
  
  # The number of elements in the queue.
  def length
    @queue.length
  end
  
  # Adds an element to the queue. No two elements can share the same priority.
  def insert(priority, value = priority)
    @queue[priority] = value
  end
  
  # The maximum priority of an element in the queue.
  def top_priority
    top_priority_and_value = @queue.last
    top_priority_and_value and top_priority_and_value.first
  end
  
  # The element with the top priority in the queue.
  def top
    top_priority_and_value = @queue.last
    top_priority_and_value and top_priority_and_value.last
  end
  
  # Deletes the element with the top priority in the queue.
  def delete_top
    top_priority_and_value = @queue.last
    @queue.delete top_priority_and_value.first
  end
end
