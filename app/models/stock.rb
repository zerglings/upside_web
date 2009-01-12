class Stock < ActiveRecord::Base
  belongs_to :market
  has_one :stock
  
  set_primary_key :ticker
  
  validates_uniquness_of :market_id,
                         :allow_nil => false
  validates_uniqueness_of :ticker,
                          :allow_nil => false
end
