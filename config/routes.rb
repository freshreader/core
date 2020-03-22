Rails.application.routes.draw do
  resources :articles

  get '/', to: 'home#show', as: :index

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'logout', to: 'sessions#destroy'

  post 'signup', to: 'users#create'

  get 'account', to: 'users#show'
  delete 'account', to: 'users#destroy'
end
