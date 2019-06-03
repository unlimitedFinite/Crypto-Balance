class Order < ApplicationRecord
  belongs_to :base_coin, class_name: 'Coin'
  belongs_to :target_coin, class_name: 'Coin'
  belongs_to :portfolio

  validates :base_coin, :target_coin, :status, :side, :type, :price, :quantity, :commission, :binance_id, presence: true
  validates :binance_id, uniqueness: true
  validates :status, inclusion: { in: %w(NEW PARTIALLY_FILLED FILLED CANCELED REJECTED EXPIRED) }
  validates :side, inclusion: { in: %w(BUY SELL) }
  validates :type, inclusion: { in: %w(MARKET) } # For now, will limit to market orders only
end
