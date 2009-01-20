class SessionsController < ApplicationController
  protect_from_forgery :except => [:create]
  
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
        if params[:device_id]
          device = Device.find :first,
                               :conditions => {:unique_id => params[:device_id]}
          device.update_attributes! :user => @user if device
        end
        
        format.html { redirect_to @user.portfolio }
        format.xml # create.xml.builder
      else
        session[:user_id] = nil
        flash[:error] = "Invalid user/password combination"
        format.html { render :action => :new }
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
