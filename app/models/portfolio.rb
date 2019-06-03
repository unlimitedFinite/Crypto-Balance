class Portfolio < ApplicationRecord
  belongs_to :user
  has_one :coin
  has_many :positions

  validates :rebalance_freq, :coin, presence: true
end
