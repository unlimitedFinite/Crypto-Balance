require 'sidekiq-scheduler'
require 'date'
require_relative '../models/portfolio'

class RebalancePortfolioJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    portfolios = Portfolio.all
    portfolios.each do |portfolio|
      next unless Date.today == portfolio.next_rebalance_dt

      portfolio.rebalance
      if portfolio.rebalance_freq == 'Daily'
        portfolio.next_rebalance_dt = portfolio.next_rebalance_dt.tomorrow
      elsif portfolio.rebalance_freq == 'Weekly'
        portfolio.next_rebalance_dt = portfolio.next_rebalance_dt.next_day(7)
      elsif portfolio.rebalance_freq == 'Biweekly'
        portfolio.next_rebalance_dt = portfolio.next_rebalance_dt.next_day(14)
      elsif portfolio.rebalance_freq == 'Monthly'
        portfolio.next_rebalance_dt = portfolio.next_rebalance_dt.next_month(1)
      else
        portfolio.next_rebalance_dt = portfolio.next_rebalance_dt.next_month(3)
      end
      portfolio.save
    end
  end
end
