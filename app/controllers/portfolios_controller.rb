class PortfoliosController < ApplicationController
  before_filter :ensure_user_authenticated, :only => [:show, :sync]
  before_filter :ensure_admin_authenticated, :except => [:show, :sync]
  before_filter :ensure_user_owns_portfolio, :except => [:index]
  protect_from_forgery :except => [:sync]
  
  # Before filter to ensure that users cannot view or sync portfolios with a different user. 
  # If the authentication works, the @s_user instance variable is set.
  # Otherwise, the response is a redirect back to the portfolio of the user. 
  def ensure_user_owns_portfolio
    return false unless ensure_user_authenticated
    if params[:id].to_i == 0
      @portfolio = @s_user.portfolio
    else
      @portfolio = Portfolio.find(:first, :conditions => {:id => params[:id]})
    end

    return true if @s_user == @portfolio.user || @s_user.is_admin?
    respond_to do |format|
      format.html do
        flash[:error] = 'Admin access only.'
        redirect_to @s_user.portfolio
      end
      format.xml do
        render :xml => { :error => { :message => 'Admin access only.',
                                     :reason => :denied } }
      end
    end
    return false
  end
  
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
    @positions = @portfolio.positions
    @trade_orders = @portfolio.trade_orders
    @trades = @portfolio.trades
    
    respond_to do |format|
      format.html { redirect_to @portfolio }
      format.xml # portfolios/sync.xml.builder
    end
  end
end
