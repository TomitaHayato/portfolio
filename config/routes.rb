Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "top_pages#index"
  resources :users, only: %i[ new create ]
  resources :my_pages, only: %i[ index ]
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
end
