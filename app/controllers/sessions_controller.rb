class SessionsController < ApplicationController
  before_filter :ensure_user_authenticated, :only => [:index]
  protect_from_forgery :except => [:create]
  
  def new
    session[:user_id] = nil
    respond_to do |format|
      format.html # new.html.erb
      format.js # TODO(overmind): javascript login
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
        
        format.html do
          redirect_to :controller => :welcome, :action => :dashboard
        end
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
    redirect_to :controller => :welcome, :action => :dashboard
  end
end
