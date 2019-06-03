class Coin < ApplicationRecord
  belongs_to :portfolio
  belongs_to :order
  belongs_to :allocation

  validates :name, :symbol, :current_price, presence: true
  validates :name, uniqueness: { scope: :symbol }
end
