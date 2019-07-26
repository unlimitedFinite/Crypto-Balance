require 'sidekiq-scheduler'
require_relative '../models/portfolio'

class GetPositionsJob < ApplicationJob
  queue_as :default



  def perform
    portfolios = Portfolio.all
    portfolios.each do |portfolio|
      Binance::Api::Configuration.api_key = portfolio.user.api_key
      Binance::Api::Configuration.secret_key = portfolio.user.secret_key
      portfolio.update_positions
    end
  end
end
