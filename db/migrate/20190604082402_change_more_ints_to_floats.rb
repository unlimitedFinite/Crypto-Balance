class ChangeMoreIntsToFloats < ActiveRecord::Migration[5.2]
  def change
    change_column :portfolios, :current_value, :float
    change_column :orders, :quantity, :float
  end
end
