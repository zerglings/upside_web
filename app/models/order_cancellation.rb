class OrderCancellation < ActiveRecord::Base
  belongs_to :trade_order
  
  # trade order being cancelled
  validates_uniqueness_of :trade_order_id, :allow_nil => false
  validates_numericality_of :trade_order_id, :allow_nil => false
end
