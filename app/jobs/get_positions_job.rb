require 'sidekiq-scheduler'
require_relative '../models/portfolio'

class GetPositionsJob < ApplicationJob
  queue_as :default

  def perform
    portfolios = Portfolio.all
    portfolios.each do |portfolio|
      portfolio.update_positions
    end
  end
end
