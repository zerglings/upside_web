xml.instruct! :xml, :version => "1.0"

xml.response do |response|
  xml.device do |device|
    device.uniqueId @device.unique_id
    device.userId @device.user.id
    device.modelId @device.id
  end
  xml.user do |user|
    user.name @device.user.name
    user.isPseudoUser @device.user.pseudo_user?
    user.modelId @device.user.id
  end
end
