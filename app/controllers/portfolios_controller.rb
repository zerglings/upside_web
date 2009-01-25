class PortfoliosController < ApplicationController
  before_filter :ensure_user_authenticated
  protect_from_forgery :except => [:sync]
  
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
    @portfolio = Portfolio.find(params[:id])
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
    @portfolio = Portfolio.find(params[:id])
  end
  private :edit

  # PUT /portfolios/1
  # PUT /portfolios/1.xml
  def update
    @portfolio = Portfolio.find(params[:id])

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
  private :update
  
  def sync
    if params[:id].to_i == 0
      @portfolio = @s_user.portfolio
    else
      @portfolio = Portfolio.find(params[:id])
    end
    
    @positions = @portfolio.positions
    @trade_orders = @portfolio.trade_orders
    @trades = @portfolio.trades
    
    respond_to do |format|
      format.html { redirect_to @portfolio }
      format.xml # portfolios/sync.xml.builder
    end
  end
end
