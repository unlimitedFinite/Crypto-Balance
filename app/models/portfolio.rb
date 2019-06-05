class Portfolio < ApplicationRecord
  belongs_to :user
  belongs_to :coinparams
  has_many :positions
  has_many :allocations

  validates :rebalance_freq, inclusion: { in: %w[Daily Weekly Biweekly Monthly Quarterly] }
  validates :rebalance_freq, :coin_id, presence: true
end
