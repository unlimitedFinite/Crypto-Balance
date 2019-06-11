class OrdersController < ApplicationController
  skip_before_action :authenticate_user!

  def create
  end

  def index
    @portfolios = Portfolio.all
    @portfolio = Portfolio.find(params[:portfolio_id])
    @orders = Order.all
    @coins = Coin.all
  end

  def update
  end
end

private


