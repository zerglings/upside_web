class TradesController < ApplicationController
  before_filter :ensure_admin_authenticated
  
  # GET /trades
  # GET /trades.xml
  def index
    @trades = Trade.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trades }
    end
  end

  # GET /trades/1
  # GET /trades/1.xml
  def show
    @trade = Trade.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trade }
    end
  end

  # GET /trades/new
  # GET /trades/new.xml
  def new
    @trade = Trade.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trade }
    end
  end

  # GET /trades/1/edit
  def edit
    @trade = Trade.find(params[:id])
  end

  # POST /trades
  # POST /trades.xml
  def create
    @trade = Trade.new(params[:trade])

    respond_to do |format|
      if @trade.save
        flash[:notice] = 'Trade was successfully created.'
        format.html { redirect_to(@trade) }
        format.xml  { render :xml => @trade, :status => :created, :location => @trade }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trade.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trades/1
  # PUT /trades/1.xml
  def update
    @trade = Trade.find(params[:id])

    respond_to do |format|
      if @trade.update_attributes(params[:trade])
        flash[:notice] = 'Trade was successfully updated.'
        format.html { redirect_to(@trade) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trade.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trades/1
  # DELETE /trades/1.xml
  def destroy
    @trade = Trade.find(params[:id])
    @trade.destroy

    respond_to do |format|
      format.html { redirect_to(trades_url) }
      format.xml  { head :ok }
    end
  end
end
