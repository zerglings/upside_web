module TradesHelper
  def trade_to_xml_builder(parent_node, trade)
    parent_node.trade do |output|
      output.model_id trade.id
      output.quantity trade.quantity
      output.price trade.price
    end
  end
  
  def trade_to_json_hash(trade)
    {
      :model_id => trade.id,
      :quantity => trade.quantity,
      :price => trade.price,
    }
  end
end
