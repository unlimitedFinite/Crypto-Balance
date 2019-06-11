class OrdersController < ApplicationController
  skip_before_action :authenticate_user!

  def create
  end

  def index
    @orders = Order.all
  end

  def update
  end
end

private

