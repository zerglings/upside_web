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
    new_orders =
        TradeOrder.find(:all, :conditions =>
                        "id > #{@last_order_id} AND unfilled_quantity > 0")
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
    spreads = YahooFetcher.spread_data_for_tickers(tickers).map do |data|
      [data[:bid], data[:ask]]
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
    buy_queue, sell_queue = queues_for_stock(stock_id, official_spread)
    trades = @merger.merge_queues buy_queue, sell_queue, official_spread
    [buy_queue, sell_queue].flatten.each { |order| @store << order }
    return trades
  end

  # Generate trades from all available pending orders.
  def generate_trades
    trades = []
    spreads_in_store.each do |stock_info|
      trades += trades_for_stock *stock_info
    end
    return trades
  end

  # Execute trades generated by the order merger.
  def execute_trades(trades)
    Trade.transaction do
      trades.each do |trade|
        trade.execute
        trade.save!
      end
    end
  end
  
  # Perform a full round of the order matching process.
  def round
    sync_store
    trades = generate_trades
    # TODO(overmind): uncomment the line below after folding in execution
    #execute_trades trades
    return trades
  end
end