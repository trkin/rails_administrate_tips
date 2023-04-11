Rails.application.routes.draw do
  namespace :admin do
    resources :stats, only: [:index]
    resources :users
    resources :books do
      member do
        patch :publish
        get :manage_categories
      end
    end
    resources :comments
    resources :categories
    resources :book_categories, except: :index

    root to: "stats#index"
  end
  resources :categories
  resources :books
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "books#index"
end
