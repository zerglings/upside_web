xml.instruct! :xml, :version => "1.0"

xml.sync do |sync|
  @positions.each do |position|
    sync.position do |output|
      output.model_id position.id
      output.ticker position.stock.ticker
      output.quantity position.quantity
      output.is_long position.is_long
    end
  end
  
  @trade_orders.each do |trade_order|
    trade_order_to_xml_builder sync, trade_order
  end
  
  @trades.each do |trade|
    sync.trade do |output|
      output.model_id trade.id
      output.quantity trade.quantity
      output.price trade.price
    end
  end
end
