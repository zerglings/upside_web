class Matching::OrderMerger
  # Fills an order by creating an associated trade.
  def fill_order(queue, order, price, quantity, trade_list)
    trade = Trade.new :quantity => quantity,
                      :price => price,
                      :trade_order => order,
                      :counterpart_id => nil,
                      :time => Time.now
    order.unfilled_quantity -= quantity
    queue.shift if order.unfilled_quantity == 0
    trade_list << trade
  end
 
  
  # The first order to be extrated out of the buy queue.
  # The buy queue is actually two queues, for limit orders and market orders.
  # Market orders are interleaved with limit orders, assuming their prices are
  # set at the official ask price.
  def first_buy_order(buy_orders, official_spread)
    # buy_orders[0] is the queue for limit orders
    # buy_orders[1] is the queue for market orders
    return buy_orders[1], buy_orders[1].first if buy_orders[0].empty?
    
    limit_order = buy_orders[0].first
    if limit_order.limit_price < official_spread[1]      
      return buy_orders[1], buy_orders[1].first unless buy_orders[1].empty?
    end
    return buy_orders[0], limit_order
  end
  
  # The first order to be extrated out of the sell queue.
  # The sell queue is actually two queues, for limit orders and market orders.
  # Market orders are interleaved with limit orders, assuming their prices are
  # set at the official bid price.
  def first_sell_order(sell_orders, official_spread)
    # sell_orders[0] is the queue for limit orders
    # sell_orders[1] is the queue for market orders
    return sell_orders[1], sell_orders[1].first if sell_orders[0].empty?
    
    limit_order = sell_orders[0].first
    if limit_order.limit_price > official_spread[0]      
      return sell_orders[1], sell_orders[1].first unless sell_orders[1].empty?
    end
    return sell_orders[0], limit_order
  end
  
  # Attempts to create a trade out of the heads of the buy & sell order queues.
  def merge_step(buy_orders, sell_orders, official_spread, order_filler)
    buy_queue, buy_order = first_buy_order buy_orders, official_spread
    return false unless buy_order
    sell_queue, sell_order = first_sell_order sell_orders, official_spread
    return false unless sell_order
    
    buy_price = buy_order.limit_price || official_spread.last
    sell_price = sell_order.limit_price || official_spread.first
    return false if buy_price < sell_price
    # divides by 2 and rounds to cents
    price = Stock.clean_price((buy_price + sell_price) / 2)
    quantity = [buy_order.unfilled_quantity, sell_order.unfilled_quantity].min
    
    order_filler.call buy_queue, buy_order, price, quantity
    order_filler.call sell_queue, sell_order, price, quantity
    return true
  end

  # Fills all orders in a queue, using the given price.
  def drain_with_price(queue, price, order_filler)
    until queue.empty?
      order = queue.first
      order_filler.call queue, order, price, order.unfilled_quantity
    end
  end
  
  # Fills the orders in a queue where the limit matches a certain limit.
  # Limits are compared using the limit operator.
  def drain_with_limit_price(queue, limit_price, limit_operator, order_filler)
    until queue.empty?
      order = queue.first
      break if order.limit_price.send limit_operator, limit_price
      order_filler.call queue, order, limit_price, order.unfilled_quantity
    end
  end
  
  # Fills all the orders in the queues that can be filled using the official
  # ask and bid prices.
  def drain_queues(buy_orders, sell_orders, official_spread, order_filler)
    drain_with_price buy_orders[1], official_spread.last, order_filler    
    drain_with_price sell_orders[1], official_spread.first, order_filler
    drain_with_limit_price buy_orders[0], official_spread.last, :<,
                           order_filler    
    drain_with_limit_price sell_orders[0], official_spread.first, :>,
                           order_filler
  end

  # Attempts to fill as many orders as possible.
  # Returns an array of the created trades.
  # Removes the completely filled orders from the queues.
  def merge_queues(buy_orders, sell_orders, official_spread)
    trades = []
    order_filler = lambda do |queue, trade, price, quantity|
      fill_order queue, trade, price, quantity, trades
    end
    
    nil while merge_step buy_orders, sell_orders, official_spread, order_filler
    drain_queues buy_orders, sell_orders, official_spread, order_filler
    return trades
  end
end
