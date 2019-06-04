class ChangePositionIntsToFloats < ActiveRecord::Migration[5.2]
  def change
    change_column :positions, :current_value, :float
    change_column :positions, :current_quantity, :float
  end
end
