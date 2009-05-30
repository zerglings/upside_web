xml.instruct! :xml, :version => "1.0"

xml.response do |response|
  device_to_xml_builder xml, @device
  user_to_xml_builder xml, @device.user
end
