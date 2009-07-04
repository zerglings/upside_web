class MonitoringController < ApplicationController
  def gadget
    stats = {
      :created_at => Time.now.to_s(:rfc822),
      :devices => Device.count,
      :load => Sys::CPU.load_avg.map { |i| (i * 1000.0).round / 1000.0 },
      :orders => TradeOrder.count,
      :stocks => Stock.count,
      :trades => Trade.count,
      :users => User.count,
      :warnings => WarningFlag.count
    }

    render :json => stats, :callback => params['callback']
  end
end
