xml.instruct! :xml, :version => "1.0"

if @trade_order.new_record?
  # saving failed
  xml.error do |error|
    error.message flash[:error]
    error.reason 'validation'
    error.details @trade_order.errors
  end
else
  xml.trade_order do |output|
    trade_order_to_xml_builder xml, @trade_order
  end
end
