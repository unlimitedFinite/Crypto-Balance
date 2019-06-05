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
    @positions = Position.where(portfolio: @portfolio).where(as_of_dt_end: nil)
  end

  def create_positions
    account_info = Binance::Api::Account.info!
    @positions = account_info[:balances].reject do |balance|
      balance[:free] == "0.00000000"
    end
    @portfolio.current_value = 0.0
    @positions.each do |position|
      coin = Coin.find_by(symbol: position[:asset])

      unless coin.nil?
        current_latest_position_record = Position.find_by(coin_id: coin.id, portfolio: @portfolio, as_of_dt_end: nil)
        @new_position_record = create_new_position_record(coin, position)
        unless current_latest_position_record.nil?
          current_latest_position_record.as_of_dt_end = @new_position_record.as_of_dt.yesterday
          current_latest_position_record.save
        end
        @portfolio.current_value += @new_position_record.current_value
      end
    end
    @portfolio.save
    rebalance_positions

    redirect_to portfolio_path(@portfolio)
  end

  def create_new_position_record(coin, position)
    price_to_use = @portfolio.coin.symbol == 'USDT' ? coin.usdt_price : coin.btc_price
    quantity = position[:free]
    new_position_record = Position.create(
      portfolio: @portfolio,
      coin_id: coin.id,
      current_quantity: quantity,
      # current_value: quantity.to_f * price_to_use,
      current_value: quantity.to_f * coin.btc_price,
      # finds the btc equivalent coins amount
      # DO NOT USE current_value! use quantity then convert when needed!
      as_of_dt: DateTime.now.to_date
    )
    # raise
    return new_position_record
  end

  def rebalance_positions
    @portfolio = Portfolio.find(params[:id])
    # Read data for each position in the binance account
    account_info = Binance::Api::Account.info!
    @positions = account_info[:balances].reject do |balance|
      balance[:free] == "0.00000000"
    end
    # sum the btc value of each position
    @portfolio.current_value = 0.0
    @positions.each do |position|
      coin = Coin.find_by(symbol: position[:asset])
      unless coin.nil?
        @portfolio.current_value += (position[:free].to_f * coin.btc_price)
      end
    end
    # find the position and portfolio stats
    @rebalance_hash = {}
    @allocations = Allocation.where(portfolio: @portfolio)

    @positions.each do |position|
      coin = Coin.find_by(symbol: position[:asset])
      # avoids error when there are coin positions that are not in our list
      unless coin.nil?
        # finds BTC price
        btc_price = Coin.find_by(symbol: 'BTC').usdt_price
        # calculates each position value in both btc and usdt
        position_value_btc = position[:free].to_f * coin.btc_price
        position_value_usdt = position[:free].to_f * coin.usdt_price
        # calculates usdt value of the total portfolio from the btc quantity
        portfolio_value_usdt = @portfolio.current_value * btc_price
        # calculates the pct difference between target and current allocations
        current_pct = ((position_value_usdt / portfolio_value_usdt) * 100).round(2)
        target_pct = @allocations.find { |a| a[:coin_id] == coin.id }.allocation_pct
        rebalance_pct = target_pct - current_pct
        # rebalance amount in USD
        rebalance_amount_usd = (rebalance_pct / 100) * portfolio_value_usdt
        rebalance_amount_coins = rebalance_amount_usd / coin.usdt_price
        # create hash of coins with rebalance amounts in USD
        @rebalance_hash[position[:asset]] = rebalance_amount_coins
        # reference coin price is mid, bid or offer?
      end
    end
    # call order execution function
    execute_rebalance_orders(@rebalance_hash)
  end

  def execute_rebalance_orders
    orders_array
    @rebalance_hash.each do |coin, amount|
      if amount.positive?
        side = 'BUY'
      else
        side = 'SELL'
      end
      order = Binance::Api::Order.create!(
        quantity: amount,
        side: side,
        symbol: "#{coin}BTC",
        type: 'MARKET',
        test: true
      )
      # store order response confirmation
      orders_array << order
      # Binance::Api::Order.create!(quantity: 100, side: 'SELL', symbol: 'XLMBTC', type: 'MARKET')
    end
  end

  def get_api_data(coin)
    @info = Binance::Api::Account.info!
    @depth = Binance::Api.depth!(symbol: "#{coin}BTC")
    @bid = @depth[:bids][0][0].to_f
    @offer = @depth[:asks][0][0].to_f
    @bid_quantity = @depth[:bids][0][1].to_f
    @ask_quantity = @depth[:asks][0][1].to_f
    @trade_history = Binance::Api.historical_trades!(symbol: "#{coin}BTC")
    @price_change = Binance::Api.ticker!(symbol: "#{coin}BTC")
    @trades = Binance::Api.trades!(symbol: "#{coin}BTC")
  end

end

private

def set_portfolio
  @portfolio = Portfolio.find(params[:id])
end

def portfolio_params
  params.require(:portfolio).permit(:rebalance_freq, :next_rebalance_dt, :coin_id)
end
