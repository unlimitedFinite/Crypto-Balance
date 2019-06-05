# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

run Sidekiq::Web

run Rails.application
