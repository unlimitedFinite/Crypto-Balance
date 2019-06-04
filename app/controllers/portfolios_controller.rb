require 'open-uri'
require 'json'
require 'date'

class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio, only: [:show, :create_positions]

  def new
    @portfolio = Portfolio.new
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)
    @portfolio.user = current_user
    @portfolio.coin_id = Coin.find_by(symbol: params['portfolio']['coin_id']).id
    @portfolio.next_rebalance_dt = Date.new(params["portfolio"]['next_rebalance_dt(1i)'].to_i,params["portfolio"]['next_rebalance_dt(2i)'].to_i,params["portfolio"]['next_rebalance_dt(3i)'].to_i)
    if @portfolio.save
      redirect_to new_portfolio_allocation_path(@portfolio.id)
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def show
    @allocations = Allocation.where(portfolio: @portfolio)
  end

  def create_positions
    account_info = Binance::Api::Account.info!
    positions = account_info[:balances].reject do |balance|
      balance[:free] == "0.00000000"
    end
    positions.each do |position|
      coin = Coin.find_by(symbol: position[:asset])

      unless coin.nil?
        price_to_use = @portfolio.coin.symbol == 'USDT' ? coin.usdt_price : coin.btc_price
        quantity = position[:free]
        Position.create(
          portfolio: @portfolio,
          coin_id: coin.id,
          current_quantity: quantity,
          current_value: quantity.to_f * price_to_use,
          as_of_dt: DateTime.now.to_date
        )
      end
    end
    redirect_to portfolio_path(@portfolio)
  end

  private

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end

  def portfolio_params
    params.require(:portfolio).permit(:rebalance_freq, :next_rebalance_dt, :coin_id)
  end
end
