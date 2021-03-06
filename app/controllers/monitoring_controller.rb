class MonitoringController < ApplicationController
  def gadget
    stats = {
      :created_at => Time.now.strftime('%H:%M:%S %d-%b-%Y %Z'),
      :devices => Device.count,
      :load => Sys::CPU.load_avg.map { |i| (i * 1000.0).round / 1000.0 },
      :push_notifications => ImobilePushNotification.count,
      :orders => TradeOrder.count,
      :stocks => Stock.count,
      :trades => Trade.count,
      :users => User.count,
      :warnings => WarningFlag.count
    }

    render :json => stats, :callback => params[:callback]
  end
end
