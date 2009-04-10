class MonitoringController < ApplicationController
  def gadget
    stats = {
      :devices => Device.count,
      :orders => TradeOrder.count,
      :trades => Trade.count,
      :users => User.count
    }

    render :json => stats, :callback => params['callback']
  end
end
