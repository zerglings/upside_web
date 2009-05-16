class PortfoliosController < ApplicationController
  before_filter :ensure_user_authenticated, :only => [:show, :sync]
  before_filter :ensure_admin_authenticated, :except => [:show, :sync]
  before_filter :ensure_user_owns_portfolio, :except => [:index]
  protect_from_forgery :except => [:sync]
  
  include PortfoliosHelper
  include TradesHelper
  include TradeOrdersHelper
  
  # GET /portfolios
  # GET /portfolios.xml
  def index
    @portfolios = Portfolio.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portfolios }
    end
  end

  # GET /portfolios/1
  # GET /portfolios/1.xml
  def show
    @trade_orders = @portfolio.trade_orders
    @trades = @portfolio.trades
    @positions = @portfolio.positions
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portfolio }
    end
  end

  # GET /portfolios/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /portfolios/1
  # PUT /portfolios/1.xml
  def update
    respond_to do |format|
      if @portfolio.update_attributes(params[:portfolio])
        flash[:notice] = 'Portfolio was successfully updated.'
        format.html { redirect_to(@portfolio) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portfolio.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def sync
    @portfolio = Portfolio.find :first, :conditions => { :id => @portfolio.id },
                                :include => [:positions, :stats, :trade_orders,
                                             :trades]
    @positions = @portfolio.positions
    @trade_orders = @portfolio.trade_orders.reject { |o| o.adjusting_order_id }
    @trades = @portfolio.trades
    @stats = @portfolio.stats
    
    respond_to do |format|
      format.html { redirect_to @portfolio }
      format.json do
        result = { :positions => @positions.map { |p| position_to_json_hash p },
                   :trade_orders => @trade_orders.map { |o|
                       trade_order_to_json_hash o },
                   :trades => @trades.map { |t| trade_to_json_hash t },
                   :stats => @stats.map { |s| portfolio_stat_to_json_hash s },
                   :portfolio => portfolio_to_json_hash(@portfolio) }
        render :json => result, :callback => params[:callback]
      end
      format.xml # portfolios/sync.xml.builder
    end
  end
end
