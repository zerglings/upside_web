xml.instruct! :xml, :version => "1.0"

xml.sync do |sync|
  sync.portfolio do |output|
    output.cash @portfolio.cash
  end
  
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
  
  @stats.each do |portfolio_stat|
    sync.portfolio_stat do |output|
      output.frequency portfolio_stat.frequency_string
      output.rank portfolio_stat.rank
      output.net_worth portfolio_stat.net_worth
    end
  end
  
  @trades.each do |trade|
    sync.trade do |output|
      output.model_id trade.id
      output.quantity trade.quantity
      output.price trade.price
    end
  end
end
