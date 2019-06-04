class Coin < ApplicationRecord
  has_one :portfolio
  has_one :base_coin, class_name: 'Coin', foreign_key: 'base_coin_id'
  has_one :target_coin, class_name: 'Coin', foreign_key: 'target_coin_id'
  has_one :allocation
  has_one :position

  validates :name, :symbol, presence: true
  validates :name, uniqueness: { scope: :symbol }
end
