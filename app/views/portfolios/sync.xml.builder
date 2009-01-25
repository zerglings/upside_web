xml.instruct! :xml, :version => "1.0"

xml.sync do |sync|
  @positions.each do |position|
    sync.position do |output|
      output.modelId position.id
      output.ticker position.stock.ticker
      output.quantity position.quantity
      output.isLong position.is_long
    end
  end
  
  @trade_orders.each do |trade_order|
    sync.trade_order do |output|
      output.modelId trade_order.id
      output.ticker trade_order.stock.ticker
      output.quantity trade_order.quantity
      output.isBuy trade_order.is_buy
      output.isLong trade_order.is_long
      output.limitPrice (trade_order.is_limit) ? trade_order.limit_price : 0
      output.expirationTime trade_order.expiration_time
    end
  end
  
  @trades.each do |trade|
    sync.trade do |output|
      output.modelId trade.id
      output.quantity trade.quantity
      output.price trade.price
    end
  end
end
