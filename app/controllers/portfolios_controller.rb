require 'open-uri'
require 'json'
require 'date'
require 'nokogiri'

class PortfoliosController < ApplicationController
  before_action :authenticate_user!

  before_action :set_portfolio, only: [:show, :edit, :update, :create_positions, :rebalance_positions]


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
        allocation.allocation_pct = params[:crypto][coin_name]
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
    @portfolio.update_positions
    redirect_to portfolio_path(@portfolio)
  end

  def read_portfolio_info
    @portfolio = Portfolio.find(params[:id])
    @allocations = Allocation.where(portfolio: @portfolio)

    account_info = Binance::Api::Account.info!
    @positions = account_info[:balances].reject do |balance|
      balance[:free] == "0.00000000"
    end
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

  def order_size(coinhash)
    @coin_instance = Coin.find_by(symbol: coinhash[:name])

    if coinhash[:rebalance_amount] / @coin_instance[:lot_size] < 1
      required_amount = @coin_instance[:lot_size]
    else
      required_amount = (coinhash[:rebalance_amount] / @coin_instance[:lot_size]).truncate * @coin_instance[:lot_size]
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


  def lastest_btc_price
    @depth = Binance::Api.depth!(symbol: "BTCUSDT")
    @bid_price = @depth[:bids][0][0].to_f
    @ask_price = @depth[:asks][0][0].to_f
    return @ask_price
  end


  def rebalance_positions
    @portfolio.update_positions
    @coins_arr = []
    @confirmations_arr = []
    # fetch lastest price for btc
    @price_btc = lastest_btc_price

    # Loop to check and sell down any USDT to BTC first
    read_portfolio_info
    @positions.each do |position|
    # byebug
      if position[:asset] == 'USDT'
        initialise_coin(position)

        unless @number_of_usdt <= @min_order_value_usdt \
          || @number_of_btc < order_size_btc(@number_of_btc, @min_trade_unit)

          quantity = order_size_btc(@number_of_btc, @min_trade_unit)


          order = Binance::Api::Order.create!(
            quantity: quantity,
            side: 'BUY',
            symbol: 'BTCUSDT',
            type: 'MARKET'

          )

          get_trade_confirmation(order)
          # byebug

        end
      end
    @portfolio.update_positions
    end

    puts "starting alt coin loop"


    coins_list = ['Ethereum', 'Ripple', 'Bitcoin-Cash', 'Litecoin', 'EOS', 'Cardano', 'Tether', 'Tron', 'Stellar', 'Zcash']
    coins_list.each do |name|
      coin = Coin.find_by(name: name)
      position = Position.find_by(as_of_dt_end: nil, coin_id: coin.id)

      # byebug

      unless position.nil?

        position_value_usdt = position[:quantity] * coin.price_usdt

        current_pct = (position_value_usdt / @portfolio.current_value_usdt).round(2) * 100
        target_pct = @allocations.find { |a| a[:coin_id] == coin.id }.allocation_pct
        # target_amount = target_pct *
        rebalance_pct = target_pct - current_pct
        # rebalance amount in USD
        rebalance_amount_usd = (rebalance_pct / 100) * @portfolio.current_value_usdt
        rebalance_amount_coins = rebalance_amount_usd / coin.price_usdt
        # set min order size to 0.001 BTC
        min_order_value = 0.001 / coin.price_btc
        # create hash of coins with rebalance amounts in USD
        coinhash = { name: coin[:symbol], amount: position[:quantity], rebalance_amount: rebalance_amount_coins.to_f, min_order_value: min_order_value }
        @coins_arr << coinhash

        # byebug

      end
    end
    execute_orders
    flash[:success] = "Portfolio has been rebalanced!"
    create_positions
  end


  def get_trade_confirmation(order)
    unless order == []
    @confirmations_arr << order
    Order.create(
      status: order[:status],
      price: order[:fills][0][:price],
      quantity: order[:fills][0][:qty],
      commision: order[:fills][0][:commision],
      side: order[:side],
      type: order[:type],
      binance_id: order[:orderId],
      base_coin_id: 'BTC',
      target_coin_id: Coin.find_by(order[:symbol].replace('BTC', '')).id
    )

      byebug


    end
  end


  def execute_orders
    # sell method for non BTCUSDT coins
    # sorts array to do sell orders first
    @coins_arr.sort_by! { |hsh| hsh[:amount] }

    @coins_arr.each do |coinhash|

      # byebug

      if coinhash[:rebalance_amount].positive?
        side = 'BUY'
      else
        side = 'SELL'
      end

      # byebug

      coinhash[:rebalance_amount] = coinhash[:rebalance_amount].abs

      # skip BTC execution since all coins are against BTC
      unless coinhash[:name] == 'BTC' \
        || coinhash[:rebalance_amount] <= coinhash[:min_order_value] \
        || coinhash[:rebalance_amount] <= order_size(coinhash) \
        || order_size(coinhash) == @coin_instance[:lot_size] \
        # above line prevents one lot executions!
        if side == 'SELL' && coinhash[:amount] < coinhash[:rebalance_amount]
          coinhash[:rebalance_amount] = coinhash[:amount]
        end

        quantity = order_size(coinhash)


        puts @coins_arr
        puts "executing trade for #{coinhash[:name]}"
        puts coinhash[:rebalance_amount]
        puts coinhash[:amount]
        puts side
        puts quantity


        order = Binance::Api::Order.create!(
          quantity: quantity,
          side: side,
          symbol: "#{coinhash[:name]}BTC",
          type: 'MARKET'

        )


        get_trade_confirmation(order)
      end
    end
  end


  def panic_sell
    @coins_arr = []
    @confirmations_arr = []
    read_portfolio_info
    price_update
    @price_btc = Coin.find_by(symbol: 'BTC').price_usdt

    @positions.each do |position|
      coin = Coin.find_by(symbol: position[:asset])

      # sell down BCTUSD first
      if position[:asset] == 'BTC'

        initialise_coin(position)

        unless @number_of_usdt <= @min_order_value_usdt \
          || @number_of_btc < order_size_btc(@number_of_btc, @min_trade_unit)

          quantity = order_size_btc(@number_of_btc, @min_trade_unit)

          order = Binance::Api::Order.create!(
            quantity: quantity,
            side: 'SELL',
            symbol: 'BTCUSDT',
            type: 'MARKET'
          )

          # get_trade_confirmation('BTC')

          get_trade_confirmation(order)
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

private

def set_portfolio
  @portfolio = Portfolio.find(params[:id])
end

def portfolio_params
  params.require(:portfolio).permit(:rebalance_freq, :next_rebalance_dt, :coin_id, allocations_attributes: [:crypto])
end

def create_allocations
  if params[:crypto].values.map(&:to_i).sum != 100
    flash[:failure] = "Allocation must total 100% !"
    # redirect_to new_portfolio_allocation_path(@portfolio)
  else
    params[:crypto].each do |coin, percentage|
      @allocation = Allocation.new
      @allocation.portfolio_id = @portfolio.id
      @allocation.coin_id = Coin.find_by(name: coin).id
      @allocation.allocation_pct = percentage.to_i
      @allocation.save
      usdt_coin = Coin.find_by(symbol: "USDT")
      Allocation.create(allocation_pct: 0, coin_id: usdt_coin.id, portfolio_id: @portfolio.id)
    end
    if Allocation.last.portfolio_id.nil?
      flash[:failure] = "There has been a problem allocating, Please try again!"
      render :new
    else
      flash[:success] = "Allocations have been saved!"
      redirect_to create_positions_path(@portfolio)
    end
  end
end
