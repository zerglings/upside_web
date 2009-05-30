module DevicesHelper
  def device_to_xml_builder(parent_node, device)
    parent_node.device do |output|
      output.unique_id device.unique_id
      output.hardware_model device.hardware_model
      output.os_name device.os_name
      output.os_version device.os_version
      output.app_version device.app_version
      output.user_id device.user.id
      output.model_id device.id
    end
  end
  
  def device_to_json_hash(device)
    {
      :unique_id => device.unique_id,
      :hardware_model => device.hardware_model,
      :os_name => device.os_name,
      :os_version => device.os_version,
      :app_version => device.app_version,
      :user_id => device.user.id,
      :model_id => device.id
    }
  end
end
