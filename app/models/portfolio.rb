class Portfolio < ApplicationRecord
  belongs_to :user
  has_one :coin
end
