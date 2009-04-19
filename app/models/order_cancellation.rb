# == Schema Information
# Schema version: 20090414171653
#
# Table name: order_cancellations
#
#  id             :integer(4)      not null, primary key
#  trade_order_id :integer(4)      not null
#  created_at     :datetime
#

class OrderCancellation < ActiveRecord::Base
  belongs_to :trade_order
  
  # trade order being cancelled
  validates_uniqueness_of :trade_order_id, :allow_nil => false
  validates_numericality_of :trade_order_id, :allow_nil => false
end
