Rails.application.routes.draw do
  namespace :admin do
    resources :users
    resources :comments
    resources :categories
    resources :book_categories
    resources :books

    root to: "users#index"
  end
  resources :categories
  resources :books
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "books#index"
end
