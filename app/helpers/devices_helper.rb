module DevicesHelper
  def device_to_xml_builder(parent_node, device)
    parent_node.device do |output|
      output.app_id device.app_id
      output.app_provisioning device.app_provisioning
      output.app_push_token(device.app_push_token || '') 
      output.app_version device.app_version
      output.hardware_model device.hardware_model
      output.os_name device.os_name
      output.os_version device.os_version
      output.unique_id device.unique_id
      
      output.user_id device.user.id
      output.model_id device.id
    end
  end
  
  def device_to_json_hash(device)
    {
      :app_id => device.app_id,
      :app_provisioning => device.app_provisioning,
      :app_push_token => device.app_push_token || '',
      :app_version => device.app_version,
      :hardware_model => device.hardware_model,
      :os_name => device.os_name,
      :os_version => device.os_version,
      :unique_id => device.unique_id,
      
      :user_id => device.user.id,
      :model_id => device.id
    }
  end
end
