# == Schema Information
# Schema version: 20090728042053
#
# Table name: trades
#
#  id             :integer         not null, primary key
#  time           :datetime        not null
#  quantity       :integer(8)      not null
#  trade_order_id :integer(8)      not null
#  counterpart_id :integer(8)
#  price          :decimal(8, 2)   not null
#  created_at     :datetime
#

class Trade < ActiveRecord::Base
  include ModelLimits
  include ActionView::Helpers::NumberHelper
  
  belongs_to :trade_order
  
  # trade execution time
  validates_datetime :time,
                     :allow_nil => false
  
  # quantity / number of shares exchanged
  validates_presence_of :quantity,
                        :allow_nil => false
  validates_numericality_of :quantity,
                            :only_integer => true,
                            :greater_than => 0,
                            :less_than => MAX_QUANTITY_SHARES_PER_TRADE
  
  # trade order id 
  validates_numericality_of :trade_order_id,
                            :only_integer => true,
                            :greater_than => 0,
                            :allow_nil => false
  
  # trade order id of counter-party                      
  validates_numericality_of :counterpart_id,
                            :only_integer => true,
                            :allow_nil => true
  
  # price per share
  validates_numericality_of :price,
                            :allow_nil => false,
                            :greater_than => 0,
                            :less_than_or_equal_to => MAX_PRICE_PER_SHARE
                            
  validates_format_of :price,
                      :with => /\.\d{0,2}$/,
                      :allow_nil => false
  
  def portfolio
    trade_order.portfolio
  end
  
  # Executes the trade.
  #
  # Trades are created in the trade order matcher. They are not saved until they
  # are executed. Execution means adjusting the portfolio to reflect the trade.
  #
  # As a special case, executing certain trades can create other trades, linked
  # to the same trade order. For example, if a user issues a sell for 1000 AAPL
  # when they own 10 AAPL, we interpret that as an intention to sell their 10
  # AAPLs, and short 990 AAPLs. 
  def execute
    Trade.transaction do
      execute_without_transaction!
    end
  end
    
  def execute_without_transaction!
    overflow_trade = adjust_overflowing_trade!
    
    position = trade_order.target_position    
    position.quantity += position_quantity_delta
    adjust_position_average_base_cost! position
    (position.quantity != 0) ? position.save! : position.destroy

    portfolio.cash += portfolio_cash_delta
    portfolio.clamp_cash
    portfolio.save!
    
    trade_order.unfilled_quantity -= quantity
    trade_order.save! if trade_order.changed?
    self.trade_order_id ||= trade_order.id
    
    if changed?
      (quantity != 0) ? save! : destroy
    end
        
    send_execution_notification if quantity != 0
    overflow_trade.execute_without_transaction! if overflow_trade
  end
  protected :execute_without_transaction!
  
  # The adjustment delta for the corresponding position's quantity.
  #
  # For example, a buy long order of 99 shares has a delta of +99, but a similar
  # sell long order has a delta of -99.
  def position_quantity_delta
    (trade_order.is_long? == trade_order.is_buy?) ? quantity : -quantity
  end
  
  # The adjustment delta for the corresponding portfolio's cash.
  #
  # For example, a buy order of 99 shares @ $1.00/share modifies the cash by
  # $-99.00, but a similar sell order brings a delta of $+99.00.
  def portfolio_cash_delta
    absolute_delta = quantity * price
    (trade_order.is_buy?) ? -absolute_delta : absolute_delta
  end
  
  # Adjusts this trade, if executing it direclty would be overflowing the user's
  # position.
  #
  # :call_seq:
  #   trade.adjust_overflowing_trade! -> Trade
  #
  # For example, if a user is trying to sell 1000 AAPLs, but they only own 10
  # AAPLs, this method reduces the selling trade quantity to 10, and creates an
  # overflow trade asking to short 990 AAPLs. 
  def adjust_overflowing_trade!
    position = trade_order.target_position
    final_quantity = position_quantity_delta + position.quantity
    return nil if final_quantity >= 0
    
    # If we're here, we're overflowing by -final_quantity.

    # The code below is tricky. It will create a generated trade order, but will
    # not save it. The order gets saved when the corresponding trade is
    # executed. This way, the trade matcher doesn't have to deal with the order.
    #
    # Because we're changing the trade order's quantity, we must also change its
    # unfilled quantity, so it doesn't get over-filled. This adjustment works
    # for both matching execution models:
    #   * in-process matching => these objects are shared, state is consistent
    #   * out-of-process matching => the delta between quantity and unfilled
    #                                stays constant, so everything still works
    new_order = TradeOrder.new :adjusting_order => trade_order,
                               :portfolio => trade_order.portfolio,
                               :stock => trade_order.stock,
                               :is_buy => trade_order.is_buy,
                               :is_long => !trade_order.is_long,
                               :stop_price => trade_order.stop_price,
                               :limit_price => trade_order.limit_price,
                               :expiration_time => nil,
                               :quantity => -final_quantity
    new_trade = Trade.new :trade_order => new_order,
                          :quantity => -final_quantity,
                          :time => self.time,
                          :counterpart_id => counterpart_id,
                          :price => price
    self.quantity += final_quantity
    trade_order.unfilled_quantity += final_quantity
    
    new_trade
  end
  
  def adjust_position_average_base_cost!(position)
    # TODO(nightshade): implement and test average base price
  end
  private :adjust_position_average_base_cost!
  
  # The payload for a push notification stating this trade has been executed.
  def execution_notification_payload
    text = "Executed: #{trade_order.transaction_type} #{quantity} " +
           "#{trade_order.stock.ticker} @ #{number_to_currency price}/ea. " +
           "Cash balance: #{number_to_currency trade_order.portfolio.cash}"
    { :aps => { :alert => text, :badge => 1 },
      :trade_order_id => trade_order.id }
  end
  
  # Queues notifications telling the user that this trade has completed.
  def send_execution_notification
    payload = execution_notification_payload
    trade_order.portfolio.user.notify_devices payload, self
  end
end
