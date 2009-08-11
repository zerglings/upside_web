class WarningFlagsController < ApplicationController
  before_filter :ensure_admin_authenticated

  # GET /warning_flags
  # GET /warning_flags.xml
  def index
    @warning_flags = WarningFlag.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @warning_flags }
    end
  end

  # GET /warning_flags/1
  # GET /warning_flags/1.xml
  def show
    @warning_flag = WarningFlag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @warning_flag }
    end
  end

  # GET /warning_flags/new
  # GET /warning_flags/new.xml
  def new
    @warning_flag = WarningFlag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @warning_flag }
    end
  end

  # GET /warning_flags/1/edit
  def edit
    @warning_flag = WarningFlag.find(params[:id])
  end

  # POST /warning_flags
  # POST /warning_flags.xml
  def create
    @warning_flag = WarningFlag.new(params[:warning_flag])

    respond_to do |format|
      if @warning_flag.save
        flash[:notice] = 'WarningFlag was successfully created.'
        format.html { redirect_to(@warning_flag) }
        format.xml  { render :xml => @warning_flag, :status => :created, :location => @warning_flag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @warning_flag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /warning_flags/1
  # PUT /warning_flags/1.xml
  def update
    @warning_flag = WarningFlag.find(params[:id])

    respond_to do |format|
      if @warning_flag.update_attributes(params[:warning_flag])
        flash[:notice] = 'WarningFlag was successfully updated.'
        format.html { redirect_to(@warning_flag) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @warning_flag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /warning_flags/1
  # DELETE /warning_flags/1.xml
  def destroy
    @warning_flag = WarningFlag.find(params[:id])
    @warning_flag.destroy

    respond_to do |format|
      format.html { redirect_to(warning_flags_url) }
      format.xml  { head :ok }
    end
  end
end
