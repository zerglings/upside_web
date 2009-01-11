class TradeOrdersController < ApplicationController
  # GET /trade_orders
  # GET /trade_orders.xml
  def index
    @trade_orders = TradeOrder.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trade_orders }
    end
  end

  # GET /trade_orders/1
  # GET /trade_orders/1.xml
  def show
    @trade_order = TradeOrder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trade_order }
    end
  end

  # GET /trade_orders/new
  # GET /trade_orders/new.xml
  def new
    @trade_order = TradeOrder.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trade_order }
    end
  end

  # GET /trade_orders/1/edit
  def edit
    @trade_order = TradeOrder.find(params[:id])
  end

  # POST /trade_orders
  # POST /trade_orders.xml
  def create
    @trade_order = TradeOrder.new(params[:trade_order])

    respond_to do |format|
      if @trade_order.save
        flash[:notice] = 'TradeOrder was successfully created.'
        format.html { redirect_to(@trade_order) }
        format.xml  { render :xml => @trade_order, :status => :created, :location => @trade_order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trade_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trade_orders/1
  # PUT /trade_orders/1.xml
  def update
    @trade_order = TradeOrder.find(params[:id])

    respond_to do |format|
      if @trade_order.update_attributes(params[:trade_order])
        flash[:notice] = 'TradeOrder was successfully updated.'
        format.html { redirect_to(@trade_order) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trade_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trade_orders/1
  # DELETE /trade_orders/1.xml
  def destroy
    @trade_order = TradeOrder.find(params[:id])
    @trade_order.destroy

    respond_to do |format|
      format.html { redirect_to(trade_orders_url) }
      format.xml  { head :ok }
    end
  end
end
