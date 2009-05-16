xml.instruct! :xml, :version => "1.0"

xml.sync do |sync|
  portfolio_to_xml_builder sync, @portfolio
  
  @positions.each do |position|
    position_to_xml_builder sync, position    
  end
  
  @trade_orders.each do |trade_order|
    trade_order_to_xml_builder sync, trade_order
  end
  
  @stats.each do |portfolio_stat|
    portfolio_stat_to_xml_builder sync, portfolio_stat
  end
  
  @trades.each do |trade|
    trade_to_xml_builder sync, trade
  end
end
