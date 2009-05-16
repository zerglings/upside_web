module TradeOrdersHelper
  def trade_order_to_xml_builder(parent_node, trade_order)
    parent_node.trade_order do |output|
      output.model_id trade_order.id
      output.ticker trade_order.stock.ticker
      output.quantity trade_order.quantity
      output.unfilled_quantity trade_order.unfilled_quantity
      output.is_buy trade_order.is_buy
      output.is_long trade_order.is_long
      output.limit_price((trade_order.is_limit) ? trade_order.limit_price : 0)
      output.expiration_time trade_order.expiration_time
    end    
  end
  
  def trade_order_to_json_hash(trade_order)
    {
      :model_id => trade_order.id,
      :ticker => trade_order.stock.ticker,
      :quantity => trade_order.quantity,
      :unfilled_quantity => trade_order.unfilled_quantity,
      :is_buy => trade_order.is_buy,
      :is_long => trade_order.is_long,
      :limit_price => (trade_order.is_limit ? trade_order.limit_price : 0),
      :expiration_time => trade_order.expiration_time
    }
  end
end
