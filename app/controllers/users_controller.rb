class UsersController < ApplicationController
  before_filter :ensure_admin_authenticated, :except => [:is_user_taken,
                                                         :update]
  before_filter :ensure_user_owns_account, :only => [:update]
  
  include UsersHelper
  
  
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.pseudo_user = false
    
    respond_to do |format|
      if @user.save
        flash[:notice] = "User #{@user.name} was successfully created."
        format.html { redirect_to(:controller => :sessions, :action => :new) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    params[:user].delete_if { |key, value| !['name', 'password'].include?(key) }
    if params[:user][:password]
      params[:user][:password_confirmation] ||= params[:user][:password]
    end
    
    if !@user.pseudo_user && !@s_user.is_admin? && params[:user][:name] &&
       params[:user][:name] != @user.name
      render_access_denied
      return
    end    
    @user.pseudo_user = false
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        response = { :user => user_to_json_hash(@user) }
        flash[:notice] = "User #{@user.name} was successfully updated."
        format.html do
          redirect_to :controller => :portfolios, :action => @user.portfolio.id
        end
        format.json { render :json => response, :callback => params[:callback] }
      else
        flash[:error] = "User update not accepted."
        format.html { render :action => "edit" }
        format.json do
          render_error_data :message => flash[:error], :reason => :validation          
        end
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  # GET /users/is_name_taken.json
  def is_user_taken
    @name = params[:user][:name]    
    @user = User.find :first, :conditions => { :name => @name }
    
    response = { :result => { :name => @name, :taken => @user ? true : false } }
    respond_to do |format|
      format.json { render :json => response, :callback => params[:callback] }
    end
  end  
end
