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
    @coins = Coin.all
    @allocations = Allocation.where(portfolio: @portfolio)
    @positions = Position.where(portfolio: @portfolio).where(as_of_dt_end: nil).order(current_value: :desc)
  end

  def create_positions
    account_info = Binance::Api::Account.info!
    positions = account_info[:balances].reject do |balance|
      balance[:free] == "0.00000000"
    end
    @portfolio.current_value_usdt = 0.0
    @portfolio.current_value_btc = 0.0
    positions.each do |position|
      coin = Coin.find_by(symbol: position[:asset])

      unless coin.nil?
        current_latest_position_record = Position.find_by(coin_id: coin.id, portfolio: @portfolio, as_of_dt_end: nil)
        new_position_record = create_new_position_record(coin, position)
        close_prior_position_record(current_latest_position_record, new_position_record)
        @portfolio.current_value_usdt += new_position_record.value_usdt
        @portfolio.current_value_btc += new_position_record.value_btc
      end
    end
    @portfolio.save
    redirect_to portfolio_path(@portfolio)
  end

  private

  def close_prior_position_record(position_record, new_position_record)
    unless position_record.nil?
      position_record.as_of_dt_end = new_position_record.as_of_dt.yesterday
      position_record.save
    end
  end

  def create_new_position_record(coin, position)
    quantity = position[:free]
    new_position_record = Position.create(
      portfolio: @portfolio,
      coin_id: coin.id,
      quantity: quantity,
      value_usdt: quantity.to_f * coin.price_usdt,
      value_btc: quantity.to_f * coin.price_btc,
      as_of_dt: DateTime.now.to_date
    )
    return new_position_record
  end

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end

  def portfolio_params
    params.require(:portfolio).permit(:rebalance_freq, :next_rebalance_dt, :coin_id)
  end
end
