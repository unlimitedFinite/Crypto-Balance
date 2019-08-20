require 'open-uri'
require 'json'
require 'date'
require 'nokogiri'
require 'pry-byebug'

class PortfoliosController < ApplicationController
  before_action :authenticate_user!

  before_action :set_portfolio, only: [:show, :edit, :update, :create_positions, :rebalance_positions, :panic_sell]


  def new
    @portfolio = Portfolio.new
    @portfolio.allocations.build
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)
    @portfolio.user = current_user
    @portfolio.coin_id = Coin.find_by(symbol: 'BTC').id
    @portfolio.next_rebalance_dt = Date.new(params["portfolio"]['next_rebalance_dt(1i)'].to_i, params["portfolio"]['next_rebalance_dt(2i)'].to_i, params["portfolio"]['next_rebalance_dt(3i)'].to_i)
    if @portfolio.save
      create_allocations
    else
      render :new
    end
  end

  def edit
  end

  def update
    @portfolio.coin_id = Coin.find_by(symbol: 'BTC').id
    @portfolio.update(portfolio_params)
    if @portfolio.update(portfolio_params)
      @portfolio.allocations.each do |allocation|
        coin_name = Coin.find(allocation.coin_id).name
        allocation.allocation_pct = params['allocations']['crypto'][coin_name]
        allocation.save
      end
      redirect_to portfolio_path(@portfolio)
    else
      render :edit
    end
  end

  def show
    @coins = Coin.all
    @allocations = Allocation.where(portfolio: @portfolio)
    @positions = Position.where(portfolio: @portfolio).where(as_of_dt_end: nil).order(value_usdt: :desc)
    @btc_total = get_total_btc
    @usdt_total = get_total_usdt
    @percentage = get_total_percent
  end

  def create_positions
    if current_user.api_key
      @portfolio.update_positions
    else
      @portfolio.demo = true
      @portfolio.test_positions
      @portfolio.save
    end
    redirect_to portfolio_path(@portfolio)
  end

  def get_total_usdt
    sum = 0
    @positions.each do |p|
      coin = p.coin
      sum += (p.quantity * coin.price_usdt)
    end
    return sum.round(2)
  end

  def get_total_btc
    sum = 0
    @positions.each do |p|
      coin = p.coin
      sum += (p.quantity * coin.price_btc)
    end
    return sum.round(6)
  end

  def get_total_percent
    sum = 0
    @positions.each do |p|
      coin = p.coin
      sum += ((p.quantity * coin.price_usdt)/@usdt_total) * 100
    end
    return sum.round
  end

  def rebalance_positions
    if @portfolio.demo = false
      @portfolio.rebalance
      create_positions
    else
      create_positions
    end
    flash[:success] = "Portfolio has been rebalanced!"
  end

  def panic_sell
    if @portfolio.demo == true
      @portfolio.panic_positions
    else
      @portfolio.panic
      create_positions
    end
    flash[:failure] = "Portfolio has been liquidated!"
  end

  private

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end

  def portfolio_params
    params.require(:portfolio).permit(:rebalance_freq, :next_rebalance_dt, :coin_id, allocations_attributes: [:crypto])
  end

  def create_allocations
    if params[:allocations][:crypto].values.map(&:to_i).sum != 100
      flash[:failure] = "Allocation must total 100% !"
      # redirect_to new_portfolio_allocation_path(@portfolio)
    else
      params[:allocations][:crypto].each do |coin, percentage|
        @allocation = Allocation.new
        @allocation.portfolio_id = @portfolio.id
        @allocation.coin_id = Coin.find_by(name: coin).id
        @allocation.allocation_pct = percentage.to_i
        @allocation.save
      end
      usdt_coin = Coin.find_by(symbol: "USDT")
      Allocation.create(allocation_pct: 0, coin_id: usdt_coin.id, portfolio_id: @portfolio.id)

      if Allocation.last.portfolio_id.nil?
        flash[:failure] = "There has been a problem allocating, Please try again!"
        render :new
      else
        flash[:success] = "Allocations have been saved!"
        redirect_to create_positions_path(@portfolio)

        # # if current_user.api_key
        #   redirect_to create_positions_path(@portfolio)
        # else
        #   redirect_to create_test_positions_path(@portfolio)
        # end
      end
    end
  end
end
