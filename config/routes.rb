Rails.application.routes.draw do
  resources :coins, only: [:index, :update]
  resources :positions, only: [:index, :create]
  post "portfolios/:id/create_positions", to: "portfolios#create_positions", as: "create_positions"
  patch "portfolios/:id/update_positions", to: "portolio#update_positions", as: "rebalance_positions"
  resources :portfolios, except: [:index, :destroy] do
    resources :allocations, except: [:index, :show, :destroy]
  end
  resources :orders, except: [:new, :edit, :show]
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
