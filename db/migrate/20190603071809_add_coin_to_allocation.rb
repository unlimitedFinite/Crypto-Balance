class AddCoinToAllocations < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocations, :coin, foreign_key: true
  end
end
