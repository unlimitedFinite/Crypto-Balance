class AddBtcPriceToCoins < ActiveRecord::Migration[5.2]
  def change
    rename_column :coins, :current_price, :usdt_price
    add_column :coins, :btc_price, :float
  end
end
