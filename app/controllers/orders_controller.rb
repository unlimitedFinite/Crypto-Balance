class OrdersController < ApplicationController
  skip_before_action :authenticate_user!

  def create

  end

  def index
    @server_time = Binance::Api.time!
  end

  def update
  end
end

private

