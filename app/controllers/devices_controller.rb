class DevicesController < ApplicationController
  protect_from_forgery :except => [:register]
  before_filter :ensure_iphone_request, :only => [:register]
  before_filter :ensure_admin_authenticated, :except => [:register]
  
  include DevicesHelper
  include UsersHelper
  
  # GET /devices
  # GET /devices.xml
  def index
    @devices = Device.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @devices }
    end
  end

  # GET /devices/1
  # GET /devices/1.xml
  def show
    @device = Device.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @device }
    end
  end

  # GET /devices/new
  # GET /devices/new.xml
  def new
    @device = Device.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @device }
    end
  end

  # GET /devices/1/edit
  def edit
    @device = Device.find(params[:id])
  end

  # POST /devices
  # POST /devices.xml
  def create
    @device = Device.new(params[:device])

    respond_to do |format|
      if @device.save
        flash[:notice] = 'Device was successfully created.'
        format.html { redirect_to(@device) }
        format.xml  { render :xml => @device, :status => :created, :location => @device }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @device.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /devices/1
  # PUT /devices/1.xml
  def update
    @device = Device.find(params[:id])

    respond_to do |format|
      if @device.update_attributes(params[:device])
        flash[:notice] = 'Device was successfully updated.'
        format.html { redirect_to(@device) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @device.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.xml
  def destroy
    @device = Device.find(params[:id])
    @device.destroy

    respond_to do |format|
      format.html { redirect_to(devices_url) }
      format.xml  { head :ok }
    end
  end
  
  def update_device_fields
    @device.last_ip = request.remote_ip
    @device.last_app_fprint = params[:app_sig] || ''
    @device.last_activation = Time.now
    
    if params[:device]
      [:hardware_model, :app_version, :os_name, :os_version,
       :unique_id].each do |attr|
        @device.send :"#{attr}=", params[:device][attr]
      end      
    end
  end
  private :update_device_fields
  
  # registering a device
  def register
    @device = Device.find(:first, 
              :conditions => {:unique_id => params[:unique_id]})

    if @device  
      update_device_fields
      @device.save!
    else
      User.transaction do
        user = User.new_pseudo_user(params[:unique_id])
        user.save!
        if params[:device]  # Client software newer than v0.1
          # Clients will send some attributes that they use internally.
          # We need to remove them so ActiveRecord doesn't throw an exception.
          params[:device].delete_if do |key, value|
            not Device.column_names.include? key 
          end
          @device = Device.new
        else
          @device = Device.new :hardware_model => 'unknown',
                               :app_id => 'unknown',
                               :app_provisioning => '?',
                               :app_version => '1.0',
                               :os_name => 'iPhone OS',
                               :os_version => 'unknown'
          @device.unique_id = params[:unique_id]
        end
        @device.user = user
        update_device_fields
        @device.save!
      end
    end
    
    respond_to do |format|
      format.json do
        result = { :device => device_to_json_hash(@device),
                   :user => user_to_json_hash(@device.user) }
        render :json => result, :callback => params[:callback]
      end
      format.xml # register.xml.builder
    end
  end
end
