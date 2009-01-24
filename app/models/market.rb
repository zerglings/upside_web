class Market < ActiveRecord::Base
  has_many :stocks, :dependent => :nullify
  
  validates_length_of :name, :in => 3..64, :allow_nil => false
  
  def self.for_name(name)
    market = Market.find(:first, :conditions => {:name => name})
    
    if market.nil? 
      market = Market.new(:name => name)
      market.save!
    end
    
    return market.id
  end
end
