xml.instruct! :xml, :version => "1.0"

xml.user do |user|
  user.model_id @user.id
  user.is_pseudo_user @user.pseudo_user?
  user.name @user.name
end
