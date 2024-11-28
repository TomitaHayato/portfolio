# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ('/')
  root 'top_pages#index'
  resources :users, only: %i[new create show edit update]
  resources :password_resets, only: %i[new create edit update]
  resources :my_pages, only: %i[index]
  resources :rewards, only: %i[index]

  get    'login',            to: 'user_sessions#new'
  post   'login',            to: 'user_sessions#create'
  delete 'logout',           to: 'user_sessions#destroy'
  post   'guest_login',      to: 'guest_logins#create'
  post   'linebot/callback', to: 'linebots#callback'

  resources :routines do
    resources :tasks, only: %i[create update destroy], shallow: true
    resources :copies, only: %i[create], module: :routines
    resources :plays, only: %i[create update show], param: :routine_id, module: :routines, shallow: true
  end

  namespace :routines, path: 'routine' do
    resources :actives, only: %i[update], param: :routine_id
    resources :posts, only: %i[index update], param: :routine_id
    resources :finishes, only: %i[index]
    resources :likes, only: %i[create destroy], param: :routine_id
  end

  namespace :tasks do
    resources :move_highers, only: %i[update], param: :task_id
    resources :move_lowers, only: %i[update], param: :task_id
    resources :sorts, only: %i[update], param: :task_id
  end

  namespace :users, path: 'user' do
    resources :notifications, only: %i[update], param: :user_id
  end

  post 'oauth/callback' => 'oauths#callback'
  get 'oauth/callback' => 'oauths#callback'
  get 'oauth/:provider' => 'oauths#oauth', :as => :auth_at_provider

  get 'terms', to: 'static_pages#terms'
  get 'policy', to: 'static_pages#policy'

  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    user == Rails.application.credentials.dig(:sidekiq, :user) &&
    password == Rails.application.credentials.dig(:sidekiq, :password)
  end
  mount Sidekiq::Web, at: '/sidekiq'

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  namespace :admin do
    get 'login' => 'user_sessions#new', :as => :login
    post 'login' => "user_sessions#create"
    resources :rewards, only: %i[index edit update]
    root 'dashboard#index'
  end
end
