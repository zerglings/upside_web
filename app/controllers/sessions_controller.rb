class SessionsController < ApplicationController
  before_filter :ensure_user_authenticated, :only => [:index]
  protect_from_forgery :except => [:create]
  
  include UsersHelper
  
  def new
    session[:user_id] = nil
    respond_to do |format|
      format.html # new.html.erb
      format.js # TODO(overmind): javascript login
    end
  end
  
  def create
    @user = User.authenticate params[:name], params[:password]
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

      respond_to do |format|
        format.html do
          redirect_to :controller => :welcome, :action => :dashboard
        end
        format.json do
          render :json => { :user => user_to_json_hash(@user) },
                 :callback => params[:callback]
        end
        format.xml # create.xml.builder
      end
    else
      @s_user = session[:user_id] = nil
      render_error_data :message => 'Invalid user/password combination',
                        :reason => :auth
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
