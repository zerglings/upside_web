class Matching::CountedSet
  def initialize
    @set = Hash.new
  end
  
  def add(object)
    @set[object] ||= 0
    @set[object] += 1
  end
  
  def delete(object)
    return unless count = @set[object]
    if count == 1
      @set.delete object
    else
      @set[object] = count - 1
    end
  end
  
  def to_a
    @set.keys
  end
  
  alias_method :<<, :add
end
