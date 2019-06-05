class Addnewcoincolumns < ActiveRecord::Migration[5.2]
  def change
    add_column :coins, :lot_size, :decimal
    add_column :coins, :color, :string
    add_column :coins, :image, :string
  end
end
