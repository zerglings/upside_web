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
        if params[:device]  # Client software newer than v0.1
          device_id = params[:device][:unique_id]
          device = Device.find :first,
                               :conditions => { :unique_id => device_id }
          device.user = @user
          
          # Clients will send some attributes that they use internally.
          # We need to remove them so ActiveRecord doesn't throw an exception.
          params[:device].delete_if do |key, value|
            not Device.column_names.include? key 
          end
          device.update_attributes! params[:device]
          device.last_app_fprint = params[:app_sig] || ''
          device.last_ip = request.remote_ip
          device.save!
        elsif params[:device_id]  # Client software v0.1
          device = Device.find :first,
                               :conditions => {:unique_id => params[:device_id]}
          if device
            device.update_attributes! :user => @user,
                                      :last_ip => request.remote_ip,
                                      :last_app_fprint => ''
          end
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
