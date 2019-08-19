class AddDemoToPortfolio < ActiveRecord::Migration[5.2]
  def change
    add_column :portfolios, :demo, :boolean
  end
end
