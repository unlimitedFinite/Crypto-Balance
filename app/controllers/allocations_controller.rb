class AllocationsController < ApplicationController
  before_action :set_allocation, only: [:update, :edit]

  def new
    @allocation = Allocation.new
    @portfolio = Portfolio.find(params[:portfolio_id])
  end

  def show
  end

  def create
    # @portfolio = Portfolio.find(params[:portfolio_id])
    @allocation = Allocation.new(allocation_params)
    @portfolio = params[:portfolio_id]

    if params[:crypto].values.map(&:to_i).sum != 100
      flash[:failure] = "Allocation must total 100% !"
      redirect_to new_portfolio_allocation_path(@allocation.portfolio_id)
    else
      params[:crypto].each do |coin, percentage|
        @allocation = Allocation.new
        @allocation.portfolio_id = @portfolio
        @allocation.coin_id = Coin.find_by(name: coin).id
        @allocation.allocation_pct = percentage.to_i
        @allocation.save
      end
      unless Allocation.last.portfolio_id.nil?
        flash[:success] = "Allocations have been saved!"
        redirect_to portfolio_path(@allocation.portfolio_id)
      else
        flash[:failure] = "There has been a problem allocating, Please try again!"
        redirect_to new_portfolio_allocation_path(@allocation.portfolio_id)
      end
    end
  end

  def edit
    @allocation = Allocation.new
  end

  def update
    if @allocation.update(allocation_params)
      redirect_to portfolio_path
    else
      render :edit
    end
  end
end

private

def set_allocation
  @allocation = Allocation.find(params[:id])
end

def allocation_params
  params.require(:crypto).permit(:crypto)
end
