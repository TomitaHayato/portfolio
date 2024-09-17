# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ('/')
  root 'top_pages#index'
  resources :users, only: %i[new create show edit update]
  resources :my_pages, only: %i[index]
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  post 'linebot', to: 'linebots#create'

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
end
