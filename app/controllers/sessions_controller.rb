class SessionsController < ApplicationController
  def new
    session[:user_id] = nil
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  def create
    @user = User.authenticate params[:name], params[:password]
    respond_to do |format|
      if @user
        session[:user_id] = @user.id      
        format.html { redirect_to @user.portfolio }
        format.xml # create.xml.builder
      else
        session[:user_id] = nil
        format.html do
          flash[:error] = "Invalid user/password combination"
          render :action => :new
        end
        format.xml # create.xml.builder
      end      
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
