# == Schema Information
# Schema version: 20090424025419
#
# Table name: stock_infos
#
#  id           :integer(4)      not null, primary key
#  stock_id     :integer(4)      not null
#  company_name :string(128)     not null
#  created_at   :datetime
#  updated_at   :datetime
#

class StockInfo < ActiveRecord::Base
  belongs_to :stock
  
  validates_numericality_of :stock_id, :greater_than => 0, :allow_nil => false
  validates_uniqueness_of :stock_id
  
  validates_length_of :company_name, :in => 1..100, :allow_nil => false
  
end
