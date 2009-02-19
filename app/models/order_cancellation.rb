# == Schema Information
# Schema version: 20090120032718
#
# Table name: order_cancellations
#
#  id             :integer         not null, primary key
#  trade_order_id :integer         not null
#  created_at     :datetime
#

class OrderCancellation < ActiveRecord::Base
  belongs_to :trade_order
  
  # trade order being cancelled
  validates_uniqueness_of :trade_order_id, :allow_nil => false
  validates_numericality_of :trade_order_id, :allow_nil => false
end
