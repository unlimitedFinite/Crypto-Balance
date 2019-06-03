Rails.application.routes.draw do
  get 'allocations/new'
  get 'allocations/create'
  get 'allocations/edit'
  get 'allocations/update'
  get 'orders/new'
  post 'orders/create'
  get 'orders/index'
  post 'orders/update'
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
