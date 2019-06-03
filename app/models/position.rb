class Position < ApplicationRecord
  has_many :coins
  belongs_to :portfolio
end
