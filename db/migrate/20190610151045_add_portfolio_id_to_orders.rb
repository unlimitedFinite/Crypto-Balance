class AddPortfolioIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :portfolio, foreign_key: true
    add_column :orders, :commission_asset, :string
  end
end
