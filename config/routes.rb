Rails.application.routes.draw do
  namespace :api do
    # Authentication
    post "auth/register", to: "auth#register"
    post "auth/login", to: "auth#login"

    # Albums
    resources :albums
  end

  get "up" => "rails/health#show", as: :rails_health_check
end