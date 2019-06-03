class PortfoliosController < ApplicationController
  before_action :authenticate_user!

  def new
    @portfolio = Portfolio.new
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)
    @portfolio.user = current_user
    @portfolio.coin_id = Coin.find_by(symbol: params['portfolio']['coin_id']).id
    if @portfolio.save
      redirect_to root_path
    else
      render :new
    end
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
