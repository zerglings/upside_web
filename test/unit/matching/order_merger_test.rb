require 'test_helper'

class OrderMergerTest < ActiveSupport::TestCase
  def trade_order_from_line(line)
    TradeOrder.new :ticker => line[0], :is_buy => line[1],
                   :quantity => line[2], :limit_price => line[3],
                   :is_long => true, :expiration_time => Time.now + 1.day                   
  end  

  def setup
    @merger = Matching::OrderMerger.new
    @fail_filler = lambda do |queue, order, price, quant|
      raise 'No orders should be filled here'
    end
    @fills = []
    @log_filler = lambda do |queue, order, price, quant|
      assert_equal queue.first, order, 'Order not at the top of queue'
      @fills << [queue, order, price, quant]
    end
    @active_filler = lambda do |queue, order, price, quant|
      assert_equal queue.first, order, 'Order not at the top of queue'
      queue.shift
      @fills << [order, price, quant]
    end 
  end
  
  def test_fill_order_partial
    fill_queue = []
    queue = [trade_order_from_line(['AAPL', true, 1000, nil])]
    @merger.fill_order queue, queue.first, 90.0, 600, fill_queue
    assert_equal 1, queue.length, 'Partial fulfillment should not remove order'
    assert_equal 400, queue.first.unfilled_quantity, 'Wrong unfulfilled quant'
    assert_equal 1, fill_queue.length, 'One trade should be generated'
    assert_equal queue.first, fill_queue.first.trade_order,
                 'Incorrect order linked to generated trade'
    assert_equal 600, fill_queue.first.quantity, 'Incorrect quantity traded'
    assert_in_delta 90.0, fill_queue.first.price, 0.001, 'Incorrect trade price'
    assert_in_delta Time.now, fill_queue.first.time, 0.5, 'Incorrect trade time'
  end
  
  def test_fill_order_completely
    fill_queue = []
    queue = [['AAPL', true, 1000, nil], ['AAPL', true, 300, nil]].map do |line|
      trade_order_from_line line
    end
    first_order, last_order = *queue
    @merger.fill_order queue, queue.first, 90.0, 1000, fill_queue
    assert_equal [last_order], queue, 'Complete fulfillment should remove order'
    assert_equal 1, fill_queue.length, 'One trade should be generated'
    assert_equal first_order, fill_queue.first.trade_order,
                 'Incorrect order linked to generated trade'
    assert_equal 1000, fill_queue.first.quantity, 'Incorrect quantity traded'
    assert_in_delta 90.0, fill_queue.first.price, 0.001, 'Incorrect trade price'
    assert_in_delta Time.now, fill_queue.first.time, 0.5, 'Incorrect trade time'
  end
  
  def test_first_buy_order
    order1 = trade_order_from_line(['AAPL', true, 1000, 85.0])
    order2 = trade_order_from_line(['AAPL', true, 500, nil])
    
    queue = [[order1], [order2]]
    assert_equal [[order1], order1],
                 @merger.first_buy_order(queue, [80.0, 83.0]),
                 'Limit order above public ask'    
    assert_equal [[order2], order2],
                 @merger.first_buy_order(queue, [80.0, 87.0]),
                 'Limit order below public ask'
                 
    queue = [[order1], []]
    assert_equal [[order1], order1],
                 @merger.first_buy_order(queue, [80.0, 87.0]),
                 'Limit order below public ask, but no market order'
    queue = [[], [order2]]
    assert_equal [[order2], order2],
                 @merger.first_buy_order(queue, [80.0, 87.0]),
                 'No limit order'
    assert_equal nil, @merger.first_buy_order([[], []], [80, 81])[1],
                 'Order obtained by extracting from empty queue'
  end
  

  def test_first_sell_order
    order1 = trade_order_from_line(['AAPL', false, 1000, 92.0])
    order2 = trade_order_from_line(['AAPL', false, 500, nil])
    
    queue = [[order1], [order2]]
    assert_equal [[order1], order1],
                 @merger.first_sell_order(queue, [95.0, 100.0]),
                 'Limit order below public bid'
    assert_equal [[order2], order2],
                 @merger.first_sell_order(queue, [90.0, 100.0]),
                 'Limit order above public bid'
                 
    queue = [[order1], []]
    assert_equal [[order1], order1],
                 @merger.first_sell_order(queue, [90.0, 100.0]),
                 'Limit order above public bid, but no market order'
    queue = [[], [order2]]
    assert_equal [[order2], order2],
                 @merger.first_sell_order(queue, [90.0, 100.0]),
                 'No limit order'
    assert_equal nil, @merger.first_sell_order([[], []], [80, 81])[1],
                 'Order obtained by extracting from empty queue'
  end
  
  def test_merge_handles_empty_queues
    high_bid = trade_order_from_line(['AAPL', true, 1000, 92.0])
    high_ask = trade_order_from_line(['AAPL', false, 500, 95.0])
    assert_equal false,
                 @merger.merge_step([[high_bid], []], [[], []], [89.0, 90.0],
                                    @fail_filler)
    assert_equal false,
                 @merger.merge_step([[], []], [[high_ask], []], [100.0, 100.5],
                                    @fail_filler)
  end
  
  def test_merge_avoids_fails
    high_bid = trade_order_from_line(['AAPL', true, 1000, 92.0])
    high_ask = trade_order_from_line(['AAPL', false, 500, 95.0])
    market_bid = trade_order_from_line(['AAPL', true, 1000, nil])
    market_ask = trade_order_from_line(['AAPL', false, 500, nil])

    assert_equal false,
                 @merger.merge_step([[high_bid], []], [[], [market_ask]],
                                    [95.0, 100.0], @fail_filler)
    assert_equal false,
                 @merger.merge_step([[], [market_bid]], [[high_ask], []],
                                    [90.0, 92.0], @fail_filler)
    assert_equal false,
                 @merger.merge_step([[high_bid], []], [[high_ask], []],
                                    [92.0, 95.0], @fail_filler)
  end
  
  def test_merge_matches_limit_orders    
    high_bid = trade_order_from_line(['AAPL', true, 1000, 92.0])
    low_ask = trade_order_from_line(['AAPL', false, 500, 87.0])
    assert_equal true,
                 @merger.merge_step([[high_bid], []], [[low_ask], []],
                                    [89.0, 90.0], @log_filler)
    assert_equal [[[high_bid], high_bid, 89.5, 500],
                  [[low_ask], low_ask, 89.5, 500]], @fills
  end
  
  def test_merge_matches_market_orders
    market_bid = trade_order_from_line(['AAPL', true, 250, nil])
    market_ask = trade_order_from_line(['AAPL', false, 500, nil])
    assert_equal true,
                 @merger.merge_step([[], [market_bid]], [[], [market_ask]],
                                    [90.0, 92.0], @log_filler)
    assert_equal [[[market_bid], market_bid, 91.0, 250],
                  [[market_ask], market_ask, 91.0, 250]], @fills    
  end
  
  def test_drain_queues
    high_bid = trade_order_from_line(['AAPL', true, 1000, 95.0])
    high_ask = trade_order_from_line(['AAPL', false, 500, 92.0])
    low_bid = trade_order_from_line(['AAPL', true, 1000, 93.0])
    low_ask = trade_order_from_line(['AAPL', false, 500, 90.0])
    market_bid = trade_order_from_line(['AAPL', true, 1000, nil])
    market_ask = trade_order_from_line(['AAPL', false, 500, nil])
    
    @merger.drain_queues [[high_bid, low_bid], [market_bid, market_bid]],
                         [[low_ask, high_ask], [market_ask, market_ask]],
                         [91.0, 94.0], @active_filler
                         
    assert_equal [[market_bid, 94.0, 1000], [market_bid, 94.0, 1000],
                  [market_ask, 91.0, 500], [market_ask, 91.0, 500],
                  [high_bid, 94.0, 1000], [low_ask, 91.0, 500]], @fills
  end
  
  def test_merge_orders
    high_bid = trade_order_from_line(['AAPL', true, 1000, 95.0])
    low_ask = trade_order_from_line(['AAPL', false, 500, 90.0])
    market_ask = trade_order_from_line(['AAPL', false, 600, nil])
    market_bid = trade_order_from_line(['AAPL', true, 500, nil])
    low_bid = trade_order_from_line(['AAPL', true, 1000, 90.0])
    high_ask = trade_order_from_line(['AAPL', false, 500, 95.0])
    
    buy_queue = [[high_bid, low_bid], [market_bid]]
    sell_queue = [[low_ask, high_ask], [market_ask]]
    trades = @merger.merge_queues buy_queue, sell_queue, [91.0, 94.55]
    
    assert_equal [[low_bid], []], buy_queue, 'Buy queue improperly processed'
    assert_equal [[high_ask], []], sell_queue, 'Sell queue improperly processed'
    assert_equal ['92.500', '92.500', '93.000', '93.000', '92.780', '92.780',
                  '94.550'],
                 trades.map { |t| '%.3f' % t.price.to_f }, 'Bad trade prices'
    assert_equal [500, 500, 500, 500, 100, 100, 400],
                 trades.map(&:quantity), 'Bad trade quantities'
    assert_equal [high_bid, low_ask, high_bid, market_ask,
                  market_bid, market_ask, market_bid],
                 trades.map(&:trade_order), 'Bad associated orders'
  end
end
