xml.instruct! :xml, :version => "1.0"

xml.response do |response|
  xml.device do |device|
    device.unique_id @device.unique_id
    device.user_id @device.user.id
    device.model_id @device.id
  end
  xml.user do |user|
    user.name @device.user.name
    user.is_pseudo_user @device.user.pseudo_user?
    user.model_id @device.user.id
  end
end
