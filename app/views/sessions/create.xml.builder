xml.instruct! :xml, :version => "1.0"

if @user
  xml.user do |user|
    user.modelId @user.id
    user.isPseudoUser @user.pseudo_user?
    user.name @user.name
  end
else
  xml.error do |error|
    error.message flash[:error]
    error.reason "auth"
  end
end
