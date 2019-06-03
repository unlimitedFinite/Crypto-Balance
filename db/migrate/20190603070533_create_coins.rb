class CreateCoins < ActiveRecord::Migration[5.2]
  def change
    create_table :coins do |t|
      t.string :name
      t.string :symbol
      t.float :current_price
      t.boolean :is_base_coin

      t.timestamps
    end
  end
end
