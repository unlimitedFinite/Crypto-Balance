Rails.application.routes.draw do

  get 'portfolios/new'
  post 'portfolios/create'
  get 'portfolios/edit'
  post 'portfolios/update'
  get 'portfolios/show'

  get 'allocations/new'
  post 'allocations/create'
  get 'allocations/edit'
  post 'allocations/update'
  get 'orders/new'
  post 'orders/create'
  get 'orders/index'
  post 'orders/update'
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
