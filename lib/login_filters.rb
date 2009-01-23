module LoginFilters
  # Before filter ensuring a user is authenticated.
  # If the authentication works, the @s_user instance variable is set.
  # Otherwise, the response is a redirect to the login page.  
  def ensure_user_authenticated
    @s_user = session[:user_id] && User.find(:first, :conditions =>
                                             {:id => session[:user_id]})
    return true if @s_user
    respond_to do |format|
      format.html { redirect_to :controller => :sessions, :action => :new }
      format.xml do
        render :xml => { :error => { :message => 'Please log in first.',
                                     :reason => :login } }
      end
    end
    return false
  end
end
