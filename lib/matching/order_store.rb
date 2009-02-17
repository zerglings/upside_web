# Keeps track of unfilled orders, in a manner which makes it very efficient
# to determine when the orders can be filled.
class Matching::OrderStore
  def initialize
    # @limit_orders and @market_orders are similar data structures. Each is a
    # two-level hash, where the first level separates buy and sell orders, and
    # the second level separates trades according to their stock IDs.
    # Example: @limit_orders[true][2] holds all the buy orders for stock 2.
    #
    # The final values in @limit_orders and @market_orders are priority queues
    # holding orders of the same kind (limit/market, buy/sell) for some stock.
    # The priorities reflect the order that trade orders should be filled in
    # (higher bids before lower bids, earlier orders before later orders).   
    
    @limit_orders = {
      true => Hash.new,
      false => Hash.new
    }
    @market_orders = {
      true => Hash.new,
      false => Hash.new
    }
    @stock_ids = Matching::CountedSet.new
  end
  
  # The priority to be associated with an order when entering it in a priority
  # queue. 
  def self.order_priority(trade_order)
    if trade_order.is_buy?
      price_priority = trade_order.limit_price || 1_000_000_000.0
    else
      # When limit_price is an ask, using its negative as a priority puts lower
      # asks before higher asks. All prices are positive, so all limit orders
      # have negative priorities. So market orders, with priority 0, will go
      # before limit orders.
      price_priority = -(trade_order.limit_price || 0.0)
    end
    # ActiveRecord IDs reflect the order that models are created in. Therefore,
    # using their negatives prioritizes early orders over late orders. 
    return [price_priority, -trade_order.id]
  end
  
  # Inserts a new order in the data structure.
  def add(trade_order)
    stock_id = trade_order.stock_id
    if trade_order.is_limit?
      priority = Matching::OrderStore.order_priority trade_order
      bucket = @limit_orders[trade_order.is_buy?]
      bucket[stock_id] ||= Matching::PriorityQueue.new
      bucket[stock_id].insert priority, trade_order
    else
      bucket = @market_orders[trade_order.is_buy?]
      bucket[stock_id] ||= Array.new
      bucket[stock_id] << trade_order
    end
    @stock_ids << trade_order.stock_id
  end
  alias_method :<<, :add
  
  # The IDs of all the stocks in the trades in this data structure.
  def stock_ids
    @stock_ids.to_a
  end
  
  # The internal market price for a stock.
  def internal_market_price(stock_id, is_buy)
    return nil unless bucket = @limit_orders[is_buy][stock_id]
    return nil unless top_priority = bucket.top_priority
    return is_buy ? top_priority.first : -top_priority.first
  end
  
  # The spread ([highest buy, lowest sell]) for a stock ID, on the internal
  # market.
  def internal_spread(stock_id)
    [internal_market_price(stock_id, true),
     internal_market_price(stock_id, false)]
  end
  
  # Extracts the market orders for a ticker that meet a given limit price.
  #
  # Does not update stock IDs. Clients should use extract_orders.
  def delete_market_orders(stock_id, is_buy)
    orders = @market_orders[is_buy].delete stock_id
    return orders || []
  end
  
  # Extracts the limit orders for a ticker that meet a given limit price.
  #
  # Does not update stock IDs. Clients should use delete_orders.
  def delete_limit_orders(stock_id, is_buy, limit_price)
    orders = []
    bucket = @limit_orders[is_buy][stock_id]
    return orders unless limit_price and bucket
    limit_price = -limit_price unless is_buy
    while top_priority = bucket.top_priority
      break if top_priority.first < limit_price
      orders << bucket.delete_top
    end
    @limit_orders[is_buy].delete stock_id if bucket.length == 0
    return orders
  end

  # Extracts the orders for a ticker that meet a given limit price.
  def delete_orders(stock_id, is_buy, limit_price)
    limit_orders = delete_limit_orders stock_id, is_buy, limit_price
    market_orders = delete_market_orders stock_id, is_buy
    return [limit_orders, market_orders].each do |orders|
      orders.each { |o| @stock_ids.delete stock_id }
    end
  end  
end