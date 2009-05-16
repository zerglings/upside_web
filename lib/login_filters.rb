module LoginFilters
  # Before filter ensuring a user is authenticated.
  # If the authentication works, the @s_user instance variable is set.
  # Otherwise, the response is a redirect to the login page.  
  def ensure_user_authenticated
    @s_user = session[:user_id] && User.find(:first, :conditions =>
                                             {:id => session[:user_id]})
    return true if @s_user
    respond_to do |format|
      error_data = { :message => 'Please log in first.', :reason => :login }
      format.html { redirect_to :controller => :sessions, :action => :new }
      format.json do
        render :json => { :error => error_data }, :callback => params[:callback]
      end
      format.xml { render :xml => { :error => error_data } }
    end
    return false
  end
  
  # Before filter ensuring the request comes from an authenticated administrator.
  # If the authentication works, the @s_user instance variable is set.
  # Otherwise, the response is a redirect back to the page the user was on.
  def ensure_admin_authenticated
    return false unless ensure_user_authenticated    
    return true if @s_user.is_admin?
    respond_to do |format|
      error_data = { :message => 'Admin access only.', :reason => :denied }
      format.html do
        flash[:error] = error_data[:message]
        redirect_to :controller => :welcome, :action => :dashboard
      end
      format.json do
        render :json => { :error => error_data }, :callback => params[:callback]
      end
      format.xml { render :xml => { :error => error_data } }
    end
    return false
  end
end
