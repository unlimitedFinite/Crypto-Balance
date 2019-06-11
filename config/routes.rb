Rails.application.routes.draw do
  resources :coins, only: [:index, :update]
  resources :positions, only: [:index, :create]
  get "portfolios/:id/create_positions", to: "portfolios#create_positions", as: "create_positions"
  post "portfolios/:id/rebalance_positions", to: "portfolios#rebalance_positions", as: "rebalance_positions"
  post "portfolios/:id/panic_sell", to: "portfolios#panic_sell", as: "sell_positions"
  resources :portfolios, except: [:index, :destroy] do
    resources :orders, except: [:new, :edit, :show]
  end

  devise_for :users, controllers: { registrations: "registrations" }
  get "users/:id", to: "pages#user_landing", as: "landing_page"
  root to: 'pages#home'

  require "sidekiq/web"
  # authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  # end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
