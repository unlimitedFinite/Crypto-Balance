class AllocationsController < ApplicationController
  before_action :set_allocation, only: [:update, :edit]

  def new
    @allocation = Allocation.new
  end

  def create
    @allocation = Allocation.new(allocation_params)
    @allocation.portfolio_id = params[:portfolio_id]

    if params[:crypto].values.map(&:to_i).sum != 100
      flash[:failure] = "Allocation must total 100%"
      redirect_to new_allocation_path
    else
      params[:crypto].each do |coin, percentage|
        @allocation.coin_id = Coin.find(coin)
        @allocation.allocation_pct = percentage.to_i

        if @allocation.save
          redirect_to portfolio_path
        else
          render :new
        end
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
  # dont need coin_id since it is constant, can take from hash??
end
# :ETH, :XRP, :LTC, :EOS, :BitcoinCash, :ETHclassic, :ZCash, :Monero
