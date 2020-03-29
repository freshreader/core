Rails.application.routes.draw do
  resources :articles

  get '/save', to: 'articles#save_bookmarklet', as: :save_bookmarklet
  get '/save-mobile', to: 'articles#save_mobile', as: :save_mobile

  get '/', to: 'home#show', as: :index

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'logout', to: 'sessions#destroy'

  post 'signup', to: 'users#create'

  get 'account', to: 'users#show'
  delete 'account', to: 'users#destroy'
end
