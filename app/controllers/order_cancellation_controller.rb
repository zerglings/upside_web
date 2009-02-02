class OrderCancellationController < ApplicationController
  before_filter :ensure_user_authenticated
  before_filter :ensure_user_cancels_own_trade_orders
  
  # POST /order_cancellations
  # POST /order_cancellations.xml
  def create  
    @order_cancellation = OrderCancellation.new(:trade_order => @trade_order)
    respond_to do |format|
      if @order_cancellation.save
        flash[:notice] = 'Trade order was successfully cancelled.'
        format.html { redirect_to(@portfolio) }
        format.xml  { render :xml => @order_cancellation, :status => :created, :location => @order_cancellation }
      else
        flash[:error] = 'Your trade order was not cancelled.'
        format.html { redirect_to(@portfolio) }
        format.xml  { render :xml => @order_cancellation.errors, :status => :unprocessable_entity }
      end
    end
  end
end
