class SessionsController < ApplicationController
  def new
    session[:user_id] = nil
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  def create
    @user = User.authenticate params[:name], params[:password]
    if @user
      session[:user_id] = @user.id
      redirect_to @user.portfolio
    else
      flash[:error] = "Invalid user/password combination"
      render :action => :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to :action => :new
  end

  def index
    if session[:user_id] != nil
      @user = User.find session[:user_id]
    else
      flash[:error] = "Please log in"
      redirect_to :action => :new
    end
  end
end
