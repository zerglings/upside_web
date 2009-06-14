xml.instruct! :xml, :version => "1.0"

xml.trade_order do |output|
  trade_order_to_xml_builder xml, @trade_order
end
