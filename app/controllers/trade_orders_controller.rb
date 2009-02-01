class TradeOrdersController < ApplicationController
  before_filter :ensure_user_authenticated, :except => [:index, :edit, :update, :destroy]
  before_filter :ensure_admin_authenticated, :only => [:index, :edit, :update, :destroy]
  before_filter :ensure_user_owns_trade_order, :except => [:index, :new, :create]
  protect_from_forgery :except => [:create]
  
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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trade_order }
    end
  end

  # GET /trade_orders/new
  # GET /trade_orders/new.xml
  def new
    @trade_order = TradeOrder.new :expiration_time => 30.days.from_now

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trade_order }
    end
  end

  # GET /trade_orders/1/edit
  def edit
  end

  # POST /trade_orders
  # POST /trade_orders.xml
  def create
    @user = @s_user
    @portfolio = @s_user.portfolio
    # TODO(overmind): remove deletes when trade orders have execution attributes
    params[:trade_order].delete :quantity_unfilled
    params[:trade_order].delete :model_id
    @trade_order = TradeOrder.new(params[:trade_order])
    @trade_order.limit_price = nil if @trade_order.limit_price == 0
    @trade_order.portfolio = @portfolio
    
    @stock = Stock.for_ticker(@trade_order.ticker)
    if @stock != nil
      @trade_order.stock = @stock
    else 
      @trade_order.stock_id = nil
    end
    
    respond_to do |format|
      if @trade_order.save
        flash[:notice] = 'TradeOrder was successfully created.'
        format.html { redirect_to(@portfolio) }
        format.xml  # create.xml.builder
      else
        flash[:error] = 'Your trade order was not placed.'
        format.html { render :action => "new" }
        format.xml  # create.xml.builder
      end
    end
  end

  # PUT /trade_orders/1
  # PUT /trade_orders/1.xml
  def update

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
    @trade_order.destroy

    respond_to do |format|
      format.html { redirect_to(@trade_order.portfolio) }
      format.xml  { head :ok }
    end
  end 
end
