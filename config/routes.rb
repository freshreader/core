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

  resources :articles do
    delete :destroy_all, on: :collection
  end

  get '/save', to: 'articles#save_bookmarklet', as: :save_bookmarklet
  get '/save-mobile', to: 'articles#save_mobile', as: :save_mobile

  get '/', to: 'pages#index', as: :index
  get 'privacy', to: 'pages#privacy'
  get 'transparency', to: 'pages#transparency'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'logout', to: 'sessions#destroy'

  post 'signup', to: 'users#create'

  get 'account', to: 'users#show'
  delete 'account', to: 'users#destroy'

  post 'create_subscription', to: 'billing#create_subscription'
  post 'retry_invoice', to: 'billing#retry_invoice'
  post 'stripe/webhooks', to: 'billing#webhooks'
  post 'subscription_callback', to: 'billing#subscription_callback'
  post 'cancel_subscription', to: 'billing#cancel_subscription'
end
