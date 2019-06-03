class Allocation < ApplicationRecord
  belongs_to :portfolio
  has_many :coins
  validates :allocation_pct, presence: true
end
