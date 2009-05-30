module UsersHelper
  def user_to_xml_builder(parent_node, user)
    parent_node.user do |output|
      output.name user.name
      output.is_pseudo_user user.pseudo_user?
      output.model_id user.id
    end    
  end
  
  def user_to_json_hash(user)
    {
      :name => user.name,
      :is_pseudo_user => user.pseudo_user?,
      :model_id => user.id
    }
  end
end
