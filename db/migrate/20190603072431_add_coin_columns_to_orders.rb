class AddCoinColumnsToOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :base_coin, foreign_key: { to_table: :coins }
    add_reference :orders, :target_coin, foreign_key: { to_table: :coins }
    rename_column :orders, :commision, :commission
  end
end
