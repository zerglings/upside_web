require 'test_helper'

module Enumerable
  def deep_map(&block)
    map do |item|
      if item.kind_of? Enumerable
        item.deep_map(&block)
      else
        yield item
      end
    end
  end
end

class OrderStoreTest < ActiveSupport::TestCase
  @@trade_order_id = 0
  def trade_order_from_line(line)    
    returning TradeOrder.new(:ticker => line[0], :is_buy => line[1],
                             :quantity => line[2], :limit_price => line[3],
                             :is_long => true,
                             :expiration_time => Time.now + 1.day) do |order|
      @@trade_order_id += 1
      order.id = @@trade_order_id
    end
  end
  
  def setup
    @store = Matching::OrderStore.new
    @orders = [
    ['AAPL', true, 1000, nil], # 0
    ['AAPL', true, 2000, nil], # 1
    ['AAPL', false, 3000, nil], # 2
    ['AAPL', false, 4000, 80.5], # 3
    ['AAPL', false, 5000, 79.8], # 4
    ['AAPL', true, 6000, 75.3], # 5
    ['AAPL', true, 7000, 73.2], # 6
    ['GOOG', true, 8000, 298.2], # 7
    ['GOOG', true, 9000, 299.5], # 8
    ['GOOG', false, 10000, 298.5], # 9
    ['GOOG', false, 11000, 300.6], # 10
    ['MSFT', true, 12000, nil], # 11
    ['MSFT', false, 13000, nil], # 12
    ].map { |line| trade_order_from_line line }
    
    @aapl, @goog, @msft =
        *['AAPL', 'GOOG', 'MSFT'].map { |ticker| Stock.for_ticker ticker }
  end
  
  def test_stats_after_adding
    @orders.each { |o| @store << o }
    
    assert_equal [@aapl.id, @goog.id, @msft.id].sort, @store.stock_ids.sort
    assert_equal [BigDecimal('75.3'), BigDecimal('79.8')],
                 @store.internal_spread(@aapl.id)
    assert_equal [BigDecimal('299.5'), BigDecimal('298.5')],
                 @store.internal_spread(@goog.id)
    assert_equal [nil, nil], @store.internal_spread(@msft.id)
  end
    
  def test_fill_appl
    @orders.each { |o| @store << o }
    deleted = @store.delete_orders @aapl.id, true, 73.1
    assert_equal([[5, 6], [0, 1]].deep_map { |i| @orders[i] }, deleted)
    deleted = @store.delete_orders @aapl.id, false, 80.7
    assert_equal([[4, 3], [2]].deep_map { |i| @orders[i] }, deleted)
    
    assert_equal [nil, nil], @store.internal_spread(@aapl.id)
    assert_equal [@goog.id, @msft.id].sort, @store.stock_ids.sort
  end
  
  def test_two_stages_goog
    @orders.each { |o| @store << o }
    deleted = @store.delete_orders @goog.id, true, 300.0
    assert_equal [[], []], deleted, 'Blank goog buy delete'
    deleted = @store.delete_orders @goog.id, true, 299.0
    assert_equal [[@orders[8]], []], deleted, 'First real goog buy delete'
    deleted = @store.delete_orders @goog.id, true, 298.0
    assert_equal [[@orders[7]], []], deleted, 'Last goog buy delete'
    assert_equal 3, @store.stock_ids.length, 'Stocks, goog buy delete'
    
    deleted = @store.delete_orders @goog.id, true, 299.0
    assert_equal [[], []], deleted, 'Blank goog sell delete'
    deleted = @store.delete_orders @goog.id, false, 300.0
    assert_equal [[@orders[9]], []], deleted, 'First goog sell delete'
    deleted = @store.delete_orders @goog.id, false, 301.0
    assert_equal [[@orders[10]], []], deleted, 'Last goog sell delete'
    assert_equal 2, @store.stock_ids.length, 'Tickers, goog sell delete'    
  end
  
  def test_empty_delete
    assert_equal([[], []], @store.delete_orders(@aapl.id, true, 100))
    assert_equal([[], []], @store.delete_orders(@aapl.id, false, 0))
  end
end
