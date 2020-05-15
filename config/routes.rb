Rails.application.routes.draw do
  # API routes
  namespace :api do
    namespace :v1 do
      # Articles
      get '/articles', to: 'articles#index'
      post '/articles', to: 'articles#create'
      delete '/articles/:id', to: 'articles#destroy'

      # Users
      get '/users/:account_number', to: 'users#show'
      post '/users', to: 'users#create'
      delete '/users', to: 'users#destroy'
    end
  end

  resources :articles

  get '/save', to: 'articles#save_bookmarklet', as: :save_bookmarklet
  get '/save-mobile', to: 'articles#save_mobile', as: :save_mobile

  get '/', to: 'pages#index', as: :index
  get 'privacy', to: 'pages#privacy'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'logout', to: 'sessions#destroy'

  post 'signup', to: 'users#create'

  get 'account', to: 'users#show'
  delete 'account', to: 'users#destroy'

  get 'account', to: 'users#show'
end
