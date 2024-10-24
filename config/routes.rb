# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: redirect('albums')

  get 'albums', to: 'albums#index', as: 'albums'
  post 'albums', to: 'albums#create'
  get 'albums/new', to: 'albums#new', as: 'new_album'
  get 'albums/:id', to: 'albums#show', as: 'album'
  get 'albums/:id/edit', to: 'albums#edit', as: 'edit_album'
  patch 'albums/:id', to: 'albums#update'
  delete 'albums/:id', to: 'albums#destroy'
end
