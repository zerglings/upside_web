xml.instruct! :xml, :version => "1.0"

xml.device do |device|
  device.uniqueId @device.unique_id
  device.userId @device.user.id
  device.deviceId @device.id
end
