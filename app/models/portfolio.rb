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
    account_info = Binance::Api::Account.info!
    positions = account_info[:balances].reject do |balance|
      Coin.find_by(symbol: balance[:asset]).nil?
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
