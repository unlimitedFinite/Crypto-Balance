class AddTransactTimeToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :transact_time, :string
  end
end
