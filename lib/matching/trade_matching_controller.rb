class Matching::TradeMatchingController
  attr_reader :store
  
  def initialize
    @store = Matching::OrderStore.new
    @last_order_id = 0
    @merger = Matching::OrderMerger.new
  end
  
  # Fetches orders from the database that have not been fetched before.
  # Returns a list of the newly fetched orders.  
  def sync_store
    new_orders = TradeOrder.uncached do
      TradeOrder.find(:all, :conditions =>
                      "id > #{@last_order_id} AND unfilled_quantity > 0")
    end
    new_orders.each do |order|
      @store << order
      @last_order_id = order.id if order.id > @last_order_id
    end
  end
  
  # Returns the stock IDs in the store, together with their spreads.
  # Example:
  #   [[1, [73.5, 80.2]], [5, [20.52, 20.84]]]
  def spreads_in_store
    stock_ids = @store.stock_ids
    tickers = stock_ids.map { |id| Stock.find(id).ticker }
    spreads = YahooFetcher.spreads_for_tickers(tickers).map do |data|
      if data == :not_found
        # This should not happen. But it did. So, instead of crashing the
        # matcher, we set a fake spread that will let people liquidate their
        # orders quickly.
        [1.0, 1.0]
      else
        # Sometimes Yahoo throws us a curve ball and gives us prices with more
        # than 2 decimals. We don't like that, so we round.
        [data[:bid], data[:ask]].map { |p| Stock.clean_price p }
      end
    end
    return stock_ids.zip(spreads)
  end
  
  # Builds the buy and sell queues for a stock.
  def queues_for_stock(stock_id, official_spread)
    buy_queue = @store.delete_orders stock_id, true, official_spread.first
    sell_queue = @store.delete_orders stock_id, false, official_spread.last
    return buy_queue, sell_queue
  end
  
  # Generate trades from the pending orders for a stock.
  def trades_for_stock(stock_id, official_spread)
    # NOTE: sometimes, the markets are closed, and no after-hours asks or bids
    #       are available on the open market; we don't do any trades in that
    #       case, to protect the buyers from accidents like selling a stock
    #       worth around $100 using an ask of $10
    return [] if official_spread.first == 0 || official_spread.last == 0
    
    buy_queue, sell_queue = queues_for_stock(stock_id, official_spread)
    orders = [buy_queue, sell_queue].flatten
    trades = @merger.merge_queues buy_queue, sell_queue, official_spread
    
    # NOTE: this reverses the computation done inside merge_queues, because
    #       trade execution is (currently) performed by the same process as
    #       trade generation. The lines below should be removed when execution
    #       is moved into a different process.
    trades.each do |trade|
      trade.trade_order.unfilled_quantity += trade.quantity
    end
    
    [buy_queue, sell_queue].flatten.each { |order| @store << order }
    return trades
  end

  # Generate trades from all available pending orders.
  def generate_trades
    trades = []
    spreads_in_store.each do |stock_info|
      trades += trades_for_stock(*stock_info)
    end
    return trades
  end

  # Execute trades generated by the order merger.
  def execute_trades(trades)
    trades.each do |trade|
      trade.save!
      trade.execute
    end
  end
  
  # Perform a full round of the order matching process.
  def round
    sync_store
    trades = generate_trades
    execute_trades trades
    return trades
  end
end