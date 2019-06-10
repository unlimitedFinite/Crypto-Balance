class OrdersController < ApplicationController
  skip_before_action :authenticate_user!

  def create
  end

  def index
    @orders = Order.where(portfolio_id: )
  end

  def update
  end
end

private

