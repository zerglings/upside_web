class AdminController < ApplicationController
  def login
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
        redirect_to(:controller => "portfolios", :action => "show", :id => session[:user_id])
      else
        flash[:error] = "Invalid user/password combination"
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end

  def index
    if session[:user_id] != nil
      @user = User.find(session[:user_id])
    else
      flash[:error] = "Please log in"
      redirect_to(:controller => "admin", :action => "login")
    end
    
  end

end
