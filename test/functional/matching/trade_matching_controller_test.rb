require 'set'
require 'test_helper'
require 'flexmock/test_unit'

class TradeMatchingControllerTest < ActionController::IntegrationTest
  # This really is a functional test, but the controller it's testing does not
  # inherit from ActionController::Base

  fixtures :all
  
  def setup
    super
    @controller = Matching::TradeMatchingController.new
  end
  
  def trade_order_from_line(line)
    TradeOrder.new :ticker => line[0], :is_buy => line[1],
                   :quantity => line[2], :limit_price => line[3],
                   :is_long => true, :expiration_time => Time.now + 1.day,
                   :portfolio => portfolios(:rich_kid)
  end  
  
  def test_sync_store
    # initial sync should fetch the unfilled orders in the fixtures
    golden_orders = [:buy_gs_at_market, :sell_gs_low,
                     :buy_ms_high, :sell_ms_at_market].
                    map { |name| trade_orders name }
    assert_equal Set.new(golden_orders), Set.new(@controller.sync_store)
    assert_equal Set.new([stocks(:gs), stocks(:ms)].map(&:id)),
                 Set.new(@controller.store.stock_ids)
    
    # second sync should fetch newly created orders
    golden_orders = [['AAPL', true, 250, 85.5], ['MSFT', false, 10000, 23.2],
                     ['GS', true, 319, nil]].
                    map { |line| trade_order_from_line line }.
                    each { |order| order.save! }
    assert_equal golden_orders, @controller.sync_store
    assert_equal Set.new([stocks(:gs), stocks(:ms), Stock.for_ticker('AAPL'),
                          Stock.for_ticker('MSFT')].map(&:id)),
                 Set.new(@controller.store.stock_ids)
  end
  
  def mock_yahoo_fetcher
    flexmock(YahooFetcher).should_receive(:spreads_for_tickers).
                           with(['MS', 'GS']).
                           and_return([{:ask => 22.8, :bid => 20.5},
                                       {:ask => 4.20, :bid => 3.50}])
  end
  
  def test_spreads_in_store
    trade_order_from_line(['AAPL', true, 50, 95.5]).save!
    @controller.sync_store

    flexmock(YahooFetcher).should_receive(:spreads_for_tickers).
                           with(['AAPL', 'MS', 'GS']).
                           and_return([:not_found,
                                       {:ask => 22.8, :bid => 20.5},
                                       {:ask => 4.20, :bid => 3.50}])    

    assert_equal [[stocks(:aapl).id, [1.0, 1.0]],
                  [stocks(:ms).id, [20.5, 22.8]],
                  [stocks(:gs).id, [3.50, 4.20]]],
                 @controller.spreads_in_store
  end
    
  def test_queues_for_stock
    @controller.sync_store
    assert_equal [[[trade_orders(:buy_ms_high)], []],
                  [[], [trade_orders(:sell_ms_at_market)]]],
                 @controller.queues_for_stock(stocks(:ms).id, [20.5, 22.8])
  end
  
  def test_trades_for_stock_with_no_spread
    @controller.sync_store
    
    assert_equal [], @controller.trades_for_stock(stocks(:ms).id, [20.5, 0]),
                 "No trading when we don't have an ask"
    assert_equal [], @controller.trades_for_stock(stocks(:ms).id, [0, 22.8]),
                 "No trading when we don't have a bid"
  end
  
  def test_round
    mock_yahoo_fetcher
    
    trades = @controller.round
    assert_equal [:buy_ms_high, :sell_ms_at_market, :buy_ms_high,
                  :buy_gs_at_market, :sell_gs_low, :buy_gs_at_market].
                 map { |name| trade_orders(name) }, trades.map(&:trade_order)
    assert_equal [99, 99, 101, 50, 50, 50], trades.map(&:quantity)
    assert_equal ['55.50', '55.50', '22.80', '3.35', '3.35', '4.20'],
                 trades.map { |trade| '%.2f' % trade.price.to_f }
                 
    trades.map(&:trade_order).uniq.each do |trade_order|
      assert trade_order.filled?, "Order unfilled: #{trade_order.inspect}"
    end
    
    # Bought 99 MS @ 55.50 and 101 MS @ 22.80 and 50 GS @ 3.35 and 50 GS @ 4.20
    #     => -8,174.8
    assert_in_delta 241_825.20, portfolios(:match_buyer).cash, 0.001,
                 'Cash in buyer portfolio modified incorrectly'
    # Sold 99 MS @ 55.50 and 50 GS @ 3.35 => +5,662.0
    assert_in_delta 255_662.00, portfolios(:match_seller).cash, 0.001,
                 'Cash in seller portfolio modified incorrectly'
  end
  
  # test all the logic with live Yahoo data, to make sure nothing crashes 
  def test_round_live
    trades = @controller.round
    assert trades.length > 2, 'Market trade orders were not executed'
  end
end