require 'open-uri'
require 'json'
require 'date'

class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio, only: [:show, :edit, :update, :create_positions]

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
    @portfolio.coin_id = Coin.find_by(symbol: params['portfolio']['coin_id'])
    @portfolio.update(portfolio_params)
    raise
    if @portfolio.update(portfolio_params)
      redirect_to portfolio_path(@portfolio)
    else
      render :edit
    end
  end

  def show
    @coins = Coin.all
    @allocations = Allocation.where(portfolio: @portfolio)
    @positions = Position.where(portfolio: @portfolio).where(as_of_dt_end: nil).order(value_usdt: :desc)
  end

  def create_positions
    @portfolio.update_positions
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
