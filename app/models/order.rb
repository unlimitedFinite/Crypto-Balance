class Order < ApplicationRecord
  belongs_to :base_coin, class_name: 'Coin'
  belongs_to :target_coin, class_name: 'Coin'
  belongs_to :portfolio

  validates :base_coin, :target_coin, :status, :side, :order_type, :price, :quantity, :commission, :binance_id, :transact_time, presence: true
  validates :binance_id, uniqueness: true
  validates :status, inclusion: { in: %w(NEW PARTIALLY_FILLED FILLED CANCELED REJECTED EXPIRED) }
  validates :side, inclusion: { in: %w(BUY SELL) }
end
