class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :status
      t.float :price
      t.integer :quantity
      t.float :commision
      t.string :side
      t.string :type
      t.string :binance_id

      t.timestamps
    end
  end
end
