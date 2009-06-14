class TradeOrdersController < ApplicationController
  before_filter :ensure_user_authenticated, :except => [:index, :edit, :update, :destroy]
  before_filter :ensure_admin_authenticated, :only => [:index, :edit, :update, :destroy]
  before_filter :ensure_user_owns_trade_order, :except => [:index, :new, :create]
  protect_from_forgery :except => [:create]

  include TradeOrdersHelper
  
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
    # iPhone model attributes that we don't want to import
    params[:trade_order].delete :quantity_unfilled
    params[:trade_order].delete :model_id
    
    client_nonce = params[:trade_order][:client_nonce]
    @trade_order = client_nonce &&
        TradeOrder.find(:first, :conditions => {:portfolio_id => @portfolio.id,
                                                :client_nonce => client_nonce })
    unless @trade_order
      @trade_order = TradeOrder.new(params[:trade_order])
      @trade_order.limit_price = nil if @trade_order.limit_price == 0
      @trade_order.portfolio = @portfolio
    end
    
    @stock = @trade_order.stock    
    respond_to do |format|
      if @trade_order.save
        flash[:notice] = 'TradeOrder was successfully created.'
        format.html { redirect_to(@portfolio) }
        format.xml  # create.xml.builder
        format.json do
          result = { :trade_order => trade_order_to_json_hash(@trade_order) }
          render :json => result, :callback => params[:callback]
        end
      else
        flash[:error] = 'Your trade order was not placed.'
        format.html { render :action => "new" }
        format.xml do
          render_error_data :message => flash[:error], :reason => :validation
        end
        format.json do
          render_error_data :message => flash[:error], :reason => :validation          
        end
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
