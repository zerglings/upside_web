class MonitoringController < ApplicationController
  def gadget
    stats = {
      :devices => Device.count,
      :load => Sys::CPU.load_avg.map { |i| (i * 1000.0).round / 1000.0 },
      :orders => TradeOrder.count,
      :stocks => Stock.count,
      :trades => Trade.count,
      :users => User.count
    }

    render :json => stats, :callback => params[:callback]
  end
end
