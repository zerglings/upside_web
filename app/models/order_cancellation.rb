class OrderCancellation < ActiveRecord::Base
  belongs_to :trade_order
  
  # trade order being cancelled
  validates_presence_of :trade_order_id
  validates_uniqueness_of :trade_order_id
  validates_numericality_of :trade_order_id
end
