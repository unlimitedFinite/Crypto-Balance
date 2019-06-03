class CreatePortfolios < ActiveRecord::Migration[5.2]
  def change
    create_table :portfolios do |t|
      t.string :rebalance_freq
      t.date :next_rebalance_dt
      t.references :user, foreign_key: true
      t.integer :current_value
      t.references :coin, foreign_key: true

      t.timestamps
    end
  end
end
