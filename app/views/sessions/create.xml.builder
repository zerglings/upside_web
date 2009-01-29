xml.instruct! :xml, :version => "1.0"

if @user
  xml.user do |user|
    user.model_id @user.id
    user.is_pseudo_user @user.pseudo_user?
    user.name @user.name
  end
else
  xml.error do |error|
    error.message flash[:error]
    error.reason "auth"
  end
end
