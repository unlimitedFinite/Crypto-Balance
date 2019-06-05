class AddCoinValuesToPositions < ActiveRecord::Migration[5.2]
  def change
    rename_column :positions, :current_value, :value_usdt
    add_column :positions, :value_btc, :float
    rename_column :positions, :current_quantity, :quantity
    rename_column :portfolios, :current_value, :current_value_usdt
    add_column :portfolios, :current_value_btc, :float
    rename_column :coins, :usdt_price, :price_usdt
    rename_column :coins, :btc_price, :price_btc
  end
end
