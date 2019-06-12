class OrdersController < ApplicationController
  skip_before_action :authenticate_user!

  def create
  end

  def index
    @portfolios = Portfolio.all
    @portfolio = Portfolio.find(params[:portfolio_id])
    @orders = Order.all
    @coins = Coin.all
  end

  def update
  end

  def download
    # aggregate your value here



    respond_to do |format|
      format.pdf do
        pdf_html = ActionController::Base.new.render_to_string(template: 'orders/download')
        pdf = WickedPdf.new.pdf_from_string(pdf_html)
        send_data pdf, filename: 'report.pdf'
      end
    end
    # html = render_to_string(template: 'orders/report')
    # pdf = WickedPdf.new.pdf_from_string(html)

    # send_data(pdf,
    #   filename: "report.pdf",
    #   disposition: 'attachment')
  end
end

private


