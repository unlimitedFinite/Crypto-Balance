class Portfolio < ApplicationRecord
  belongs_to :user
  belongs_to :coin
  has_many :positions
  has_many :allocations
  has_many :orders

  accepts_nested_attributes_for :allocations

  validates :rebalance_freq, inclusion: { in: %w[Daily Weekly Biweekly Monthly Quarterly] }
  validates :rebalance_freq, :coin_id, presence: true

  def update_positions
    positions = []
    account_info = Binance::Api::Account.info!
    coin_list = ['BTC', 'ETH', 'XRP', 'BCHABC', 'LTC', 'EOS', 'ADA', 'USDT', 'TRX', 'XLM', 'ZEC']
    coin_list.each do |name|
      position = account_info[:balances].select { |balance| balance[:asset] == name }
      positions << position[0]
    end

    self.current_value_usdt = 0.0
    self.current_value_btc = 0.0

    positions.each do |position|
      coin = Coin.find_by(symbol: position[:asset])
      unless coin.nil?
        current_latest_position_record = Position.find_by(coin_id: coin.id, portfolio: self, as_of_dt_end: nil)
        new_position_record = create_new_position_record(coin, position)
        close_prior_position_record(current_latest_position_record, new_position_record)
        self.current_value_usdt += new_position_record.value_usdt
        self.current_value_btc += new_position_record.value_btc
      end
    end

    self.save
    insert_dummy_portfolio
  end

  def rebalance
    self.update_positions
    @coins_arr = []
    @confirmations_arr = []

    # fetch lastest price for btc
    @price_btc = lastest_btc_price

    # Loop to check and sell down any USDT to BTC first
    read_portfolio_info
    @positions.each do |position|
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

        end
      end
      self.update_positions
    end
    puts "starting alt coin loop"

    coins_list = ['Ethereum', 'Ripple', 'Bitcoin-Cash', 'Litecoin', 'EOS', 'Cardano', 'Tether', 'Tron', 'Stellar', 'Zcash']
    coins_list.each do |name|
      coin = Coin.find_by(name: name)
      position = Position.find_by(as_of_dt_end: nil, coin_id: coin.id)

      # byebug

      unless position.nil?

        position_value_usdt = position[:quantity] * coin.price_usdt

        current_pct = (position_value_usdt / self.current_value_usdt).round(2) * 100
        target_pct = @allocations.find { |a| a[:coin_id] == coin.id }.allocation_pct
        # target_amount = target_pct *
        rebalance_pct = target_pct - current_pct
        # rebalance amount in USD
        rebalance_amount_usd = (rebalance_pct / 100) * self.current_value_usdt
        rebalance_amount_coins = rebalance_amount_usd / coin.price_usdt
        # set min order size to 0.001 BTC
        min_order_value = 0.001 / coin.price_btc
        # create hash of coins with rebalance amounts in USD
        coinhash = { name: coin[:symbol], amount: position[:quantity], rebalance_amount: rebalance_amount_coins.to_f, min_order_value: min_order_value }
        @coins_arr << coinhash

        # byebug

      end
    end
    @flag = 'rebalance'
    execute_orders
  end

  def panic
    @coins_arr = []
    @confirmations_arr = []
    read_portfolio_info
    @price_btc = lastest_btc_price

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
        end

      else

        unless coin.nil? || position[:asset] == 'USDT'
          min_order_value = 0.001 / coin.price_btc
          coinhash = { name: position[:asset], amount: position[:free].to_f.abs, rebalance_amount: -position[:free].to_f.abs, min_order_value: min_order_value }
          @coins_arr << coinhash
        end
        # byebug
      end
    end
    @flag = 'panic_sell'
    execute_orders
  end

  private

  def read_portfolio_info
    @allocations = Allocation.where(portfolio: self)

    account_info = Binance::Api::Account.info!
    @positions = account_info[:balances].reject do |balance|
      Coin.find_by(symbol: balance[:asset]).nil?
    end
  end

  def execute_orders
    # sell method for non BTCUSDT coins
    # sorts array to do sell orders first
    @coins_arr.sort_by! { |hsh| hsh[:rebalance_amount] }

    @coins_arr.each do |coinhash|
      # byebug
      if coinhash[:rebalance_amount].positive?
        side = 'BUY'
      else
        side = 'SELL'
      end

      coinhash[:rebalance_amount] = coinhash[:rebalance_amount].abs
      # byebug

      # skip BTC execution since all coins are against BTC
      unless coinhash[:name] == 'BTC' \
        || coinhash[:rebalance_amount] < coinhash[:min_order_value] \
        || coinhash[:rebalance_amount] < order_size(coinhash) \
        || order_size(coinhash) == @coin_instance[:lot_size] \
        # above line prevents one lot executions!
        # below line prevents notional amount errors for sell orders

        # byebug
        if side == 'SELL' && coinhash[:amount] < coinhash[:rebalance_amount]
          coinhash[:rebalance_amount] = coinhash[:amount]
        end

        quantity = order_size(coinhash)

        puts "executing trade for #{coinhash[:name]}"
        puts coinhash[:rebalance_amount]
        puts coinhash[:amount]
        puts side
        puts quantity

        # byebug

        if @flag == 'rebalance'
          ticker = "#{coinhash[:name]}BTC"
        elsif @flag == 'panic_sell'
          ticker = "#{coinhash[:name]}USDT"
        end

        order = Binance::Api::Order.create!(
          quantity: quantity,
          side: side,
          symbol: ticker,
          type: 'MARKET'
        )

        puts order

        get_trade_confirmation(order)
      end
    end
  end

  def get_trade_confirmation(confirmation)

    unless confirmation == []
      puts @confirmations_arr
      # byebug
      @confirmations_arr << confirmation

      # byebug

      @confirmations_arr.each do |order|
        # sets base coin to the held coin
        if order[:symbol] == 'BTCUSDT'
          base_coin = Coin.find_by(symbol: 'BTC')
          target_coin = Coin.find_by(symbol: 'USDT')
        else
          ticker = order[:symbol].gsub('BTC', '')
          ticker = ticker.gsub('USDT', '')
          base_coin = Coin.find_by(symbol: ticker)
          target_coin = Coin.find_by(symbol: order[:symbol].gsub("#{base_coin[:symbol]}", ''))
        end
# byebug
        o = Order.new(
          status: order[:status],
          price: order[:fills][0][:price],
          quantity: order[:fills][0][:qty],
          commission: order[:fills][0][:commission],
          commission_asset: order[:fills][0][:commissionAsset],
          side: order[:side],
          order_type: order[:type],
          binance_id: order[:orderId],
          portfolio_id: self.id,
          base_coin_id: base_coin.id,
          target_coin_id: target_coin.id,
          transact_time: order[:transactTime]
        )
        o.save
        # byebug
      end
    end
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

  def lastest_btc_price
    @depth = Binance::Api.depth!(symbol: "BTCUSDT")
    @bid_price = @depth[:bids][0][0].to_f
    @ask_price = @depth[:asks][3][0].to_f
    # calcualtes using the 3rd live offer price in the order book to allow margin for error
    # in execution amount in a fast market

    return @ask_price
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

  def insert_dummy_portfolio
    coins_list = ['Bitcoin', 'Ethereum', 'Ripple', 'Bitcoin-Cash', 'Litecoin', 'EOS', 'Cardano', 'Tether', 'Tron', 'Stellar', 'Zcash']
    coins_list.each do |name|
      coin_record = Coin.find_by(name: name)

      if Position.find_by(coin_id: coin_record.id).nil?
        Position.create(
          portfolio: self,
          coin_id: coin_record.id,
          quantity: 0.00,
          value_usdt: 0.00,
          value_btc: 0.00,
          as_of_dt: DateTime.now.to_date
        )
      end
    end
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
      portfolio: self,
      coin_id: coin.id,
      quantity: quantity,
      value_usdt: quantity.to_f * coin.price_usdt,
      value_btc: quantity.to_f * coin.price_btc,
      as_of_dt: DateTime.now.to_date
    )
    return new_position_record
  end
end
