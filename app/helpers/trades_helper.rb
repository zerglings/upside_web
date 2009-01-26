module TradesHelper
  def trade_order_to_xml_builder(parent_node, trade_order)
    parent_node.trade_order do |output|
      output.modelId trade_order.id
      output.ticker trade_order.stock.ticker
      output.quantity trade_order.quantity
      output.isBuy trade_order.is_buy
      output.isLong trade_order.is_long
      output.limitPrice((trade_order.is_limit) ? trade_order.limit_price : 0)
      output.expirationTime trade_order.expiration_time
    end    
  end
end
