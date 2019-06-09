require 'open-uri'
require 'json'
require 'date'
require 'nokogiri'


class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio, only: [:show, :edit, :update, :create_positions]

  def new
    @portfolio = Portfolio.new
  end


  def create
    @portfolio = Portfolio.new(portfolio_params)
    @portfolio.user = current_user
    @portfolio.coin_id = Coin.find_by(symbol:'BTC').id
    @portfolio.next_rebalance_dt = Date.new(params["portfolio"]['next_rebalance_dt(1i)'].to_i, params["portfolio"]['next_rebalance_dt(2i)'].to_i, params["portfolio"]['next_rebalance_dt(3i)'].to_i)
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
    account_info = Binance::Api::Account.info!
    @positions = account_info[:balances].reject do |balance|
      balance[:free] == "0.00000000"
    end

    @portfolio.current_value_usdt = 0.0
    @portfolio.current_value_btc = 0.0
    @positions.each do |position|

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


  def read_portfolio_info
    @portfolio = Portfolio.find(params[:id])
    @allocations = Allocation.where(portfolio: @portfolio)

    account_info = Binance::Api::Account.info!
    @positions = account_info[:balances].reject do |balance|
      balance[:free] == "0.00000000"
    end
  end


  def order_size(coinhash)
    @coin_instance = Coin.find_by(symbol: coinhash[:name])

    if coinhash[:amount] / @coin_instance[:lot_size] < 1
      required_amount = @coin_instance[:lot_size]
    else
      required_amount = (coinhash[:amount] / @coin_instance[:lot_size]).truncate * @coin_instance[:lot_size]
    end
    return required_amount
  end


  def order_size_btc(number_of_btc, min_trade_unit)
    if number_of_btc / min_trade_unit < 1
      required_amount = min_trade_unit
    else
      required_amount = (number_of_btc / min_trade_unit).truncate * min_trade_unit
    end
    return required_amount
  end


  def initialise_coin(position)
    # settings for BTC or USDT

    if position[:asset] == 'BTC'
      @number_of_btc = position[:free].to_f
      @number_of_usdt = position[:free].to_f * @price_btc


    elsif position[:asset] == 'USDT'
      @number_of_usdt = position[:free].to_f
      @number_of_btc = position[:free].to_f / @price_btc
    end

    @min_order_value_usdt = 10
    @min_trade_unit = Coin.find_by(symbol: position[:asset]).lot_size

  end


  def rebalance_positions

    @coins_arr = []
    @confirmations_arr = []
    @price_btc = Coin.find_by(symbol: 'BTC').price_usdt
    read_portfolio_info

    # Loop to check and sell down any USDT to BTC first
    @positions.each do |position|

      if position[:asset] == 'USDT'
        initialise_coin(position)

        unless @number_of_usdt <= @min_order_value_usdt \
          || @number_of_btc < order_size_btc(@number_of_btc, @min_trade_unit)

          quantity = order_size_btc(@number_of_btc, @min_trade_unit)

          Binance::Api::Order.create!(
            quantity: quantity,
            side: 'BUY',
            symbol: 'BTCUSDT',
            type: 'MARKET',
            test: true
          )
          get_trade_confirmation('BTC')
      # byebug
        end
      end
    end

    puts "starting alt coin loop"

    # Loop to iterate through remaining coins
    @positions.each do |position|
      coin = Coin.find_by(symbol: position[:asset])

      unless coin.nil?

        position_value_usdt = position[:free].to_f * coin.price_usdt

        current_pct = (position_value_usdt / @portfolio.current_value_usdt).round(2)
        target_pct = @allocations.find { |a| a[:coin_id] == coin.id }.allocation_pct
        rebalance_pct = target_pct - current_pct
        # rebalance amount in USD
        rebalance_amount_usd = (rebalance_pct / 100) * @portfolio.current_value_usdt
        rebalance_amount_coins = rebalance_amount_usd / coin.price_usdt
        # set min order size to 0.001 BTC
        min_order_value = 0.001 / coin.price_btc
        # create hash of coins with rebalance amounts in USD
        coinhash = { name: position[:asset], amount: rebalance_amount_coins, min_order_value: min_order_value }
        @coins_arr << coinhash

      end
    end
    # byebug
    execute_orders
    flash[:success] = "Portfolio has been rebalanced!"
    create_positions
  end


  def get_trade_confirmation(ticker)

    if ticker == "BTC"
      order = Binance::Api::Account.trades!(symbol: "BTCUSDT")
    else
      order = Binance::Api::Account.trades!(symbol: "#{ticker}BTC")
    end

    unless order == []

      confirmations_hash = {
        symbol: order[0][:symbol], \
        trade_id: order[0][:orderId], \
        price: order[0][:price], \
        quantity: order[0][:qty], \
        commission: order[0][:commission], \
        commissionAsset: order[0][:commissionAsset], \
        order_time: order[0][:time]
      }
# byebug
      @confirmations_arr << confirmations_hash

    end
  end


  def execute_orders
    # sell method for non BTCUSDT coins
    # sorts array to do sell orders first
    @coins_arr.sort_by! { |hsh| hsh[:amount] }

    @coins_arr.each do |coinhash|
      # byebug

      if coinhash[:amount].positive?
        side = 'BUY'
      else
        side = 'SELL'
      end

      coinhash[:amount] = coinhash[:amount].abs

      # skip BTC execution since all coins are against BTC
      unless coinhash[:name] == 'BTC' \
        || coinhash[:amount] <= coinhash[:min_order_value] \
        || coinhash[:amount] <= order_size(coinhash) \
        || order_size(coinhash) == @coin_instance[:lot_size]
        # above line prevents one lot executions!
        # now does not fail for EOS where order size = minimum lot size
        # check binance tables or change in seed?
        # error catch the response and skip error :400

        quantity = order_size(coinhash)

        puts "executing trade for #{coinhash[:name]}"

        Binance::Api::Order.create!(
          quantity: quantity,
          side: side,
          symbol: "#{coinhash[:name]}BTC",
          type: 'MARKET',
          test: true
        )

      # byebug
        get_trade_confirmation(coinhash[:name])
      end
    end
  end


  def panic_sell
    @coins_arr = []
    @confirmations_arr = []
    read_portfolio_info
    @price_btc = Coin.find_by(symbol: 'BTC').price_usdt

    @positions.each do |position|
      coin = Coin.find_by(symbol: position[:asset])

      # sell down BCTUSD first
      if position[:asset] == 'BTC'

        initialise_coin(position)

        unless @number_of_usdt <= @min_order_value_usdt \
          || @number_of_btc < order_size_btc(@number_of_btc, @min_trade_unit)

          quantity = order_size_btc(@number_of_btc, @min_trade_unit)

          Binance::Api::Order.create!(
            quantity: quantity,
            side: 'SELL',
            symbol: 'BTCUSDT',
            type: 'MARKET',
            test: true
          )
          get_trade_confirmation('BTC')
          # byebug
        end

      else

        unless coin.nil?
          min_order_value = 0.001 / coin.price_btc
          coinhash = { name: position[:asset], amount: -position[:free].to_f.abs, min_order_value: min_order_value }
          @coins_arr << coinhash
          @coins_arr.sort_by { |hsh| hsh[:amount] }
        end
      end
    end
    execute_orders
    flash[:failure] = "Portfolio has been liquidated!"
    create_positions
  end


  # useful api calls - do not remove yet
  def get_api_data(coin)
    @info = Binance::Api::Account.info!
    @depth = Binance::Api.depth!(symbol: "#{coin}BTC")
    @bid = @depth[:bids][0][0].to_f
    @offer = @depth[:asks][0][0].to_f
    @bid_quantity = @depth[:bids][0][1].to_f
    @ask_quantity = @depth[:asks][0][1].to_f
    @trade_history = Binance::Api.historical_trades!(symbol: "#{coin}BTC")
    @price_change = Binance::Api.ticker!(symbol: "#{coin}BTC")
    @trades = Binance::Api::Account.trades!(symbol: "#{coin}BTC")

    #   [{:symbol=>"XLMBTC",
    # :orderId=>101810246,
    # :price=>"0.00001583",
    # :qty=>"100.00000000",
    # :quoteQty=>"0.00158300",
    # :commission=>"0.00031272",
    # :commissionAsset=>"BNB",
    # :time=>1559711013403}]

    # @symbol = order[0][:symbol]
    # @trade_id = order[0][:Id]
    # @price = order[0][:qty]
    # @commission = order[0][:commission]
    # @commissionAsset = order[0][:commissionAsset]
    # @order_time = @order[0][:time]
  end

end

private

def set_portfolio
  @portfolio = Portfolio.find(params[:id])
end

def portfolio_params
  params.require(:portfolio).permit(:rebalance_freq, :next_rebalance_dt, :coin_id)
end
