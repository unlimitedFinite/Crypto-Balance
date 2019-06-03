Rails.application.routes.draw do
  resources :coins, only: [:index, :update]
  resources :positions, only: [:index, :create]
  resources :portfolios, except: [:index, :destroy]
  resources :allocations, except: [:index, :show, :destroy]
  resources :orders, except: [:new, :edit, :show]
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
