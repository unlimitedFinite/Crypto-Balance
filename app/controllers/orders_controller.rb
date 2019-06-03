class OrdersController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    Binance::Api::Order.create!(quantity: '100.0', side: 'BUY', symbol: 'XLMETH', type: 'MARKET')
  end

  def index
    @BatTrades = Binance::Api::Order.all!(symbol: 'BATETH')
    @XlmTrades = Binance::Api::Order.all!(symbol: 'XLMETH')
  end

  def update
  end
end

private

