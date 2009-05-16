module UserFilters
  # Before filter to ensure that users cannot view or sync portfolios with a different user. 
  # If the authorization works, the @portfolio instance variable is set.
  # Otherwise, the response is a redirect back to the portfolio of the user. 
  def ensure_user_owns_portfolio
    return false unless ensure_user_authenticated
    if params[:id].to_i == 0
      @portfolio = @s_user.portfolio
    else
      @portfolio = Portfolio.find(:first, :conditions => {:id => params[:id]})
    end

    return true if @s_user == @portfolio.user || @s_user.is_admin?
    render_access_denied
  end
  
  # Before filter to ensure that users cannot create or edit trade orders for a different user. 
  # If the authorization works, the @trade_order instance variable is set. 
  # Otherwise, the response is a redirect back to the portfolio of the user. 
  def ensure_user_owns_trade_order
    return false unless ensure_user_authenticated
    @portfolio = @s_user.portfolio
    @trade_order = TradeOrder.find(:first, :conditions => {:id => params[:id]})
    return true if @s_user.is_admin? || @s_user == @trade_order.portfolio.user
    render_access_denied
  end
  
  # Before filter to ensure that users cannot cancel a trade order that is not theirs. 
  # If the authorization works, the @trade_order instance variable is set.
  # Otherwise, the response is a redirect back to the portfolio of the user. 
  def ensure_user_cancels_own_trade_orders
    return false unless ensure_user_authenticated
    @portfolio = @s_user.portfolio
    @trade_order = TradeOrder.find(:first, :conditions => {:id => params[:trade_order_id]})
    return true if @s_user.is_admin? || @s_user == @trade_order.portfolio.user
    render_access_denied
  end

  # This contains code common to both ensure_user_owns_portfolio and ensure_user_owns_trade_order
  def render_access_denied
    respond_to do |format|
      error_data = { :message => 'Admin access only.', :reason => :denied } 
      format.html do
        flash[:error] = error_data[:message]
        redirect_to :controller => :welcome, :action => :dashboard
      end
      format.json do
        render :json => { :error => error_data }, :callback => params[:callback]
      end
      format.xml { render :xml => { :error => error_data } }
    end
    return false
  end
end