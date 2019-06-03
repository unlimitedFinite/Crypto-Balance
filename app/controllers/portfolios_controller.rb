class PortfoliosController < ApplicationController
  before_action :authenticate_user!

  def new
    @portfolio = Portfolio.new
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)
    @portfolio.user = current_user
    @portfolio.coin = Coin.find(params[:id])
    raise
  end

  def edit
  end

  def update
  end

  def show
  end
end

private

def portfolio_params
  params.require(:portfolio).permit(:rebalance_freq, :next_rebalance_dt, :coin_id)
end
