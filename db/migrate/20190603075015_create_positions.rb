class CreatePositions < ActiveRecord::Migration[5.2]
  def change
    create_table :positions do |t|
      t.references :coin, foreign_key: true
      t.integer :current_quantity
      t.integer :current_value
      t.date :as_of_dt
      t.date :as_of_dt_end
      t.references :portfolio, foreign_key: true

      t.timestamps
    end
  end
end
