Rails.application.routes.draw do
  # Authentication
  post "register", to: "auth#register"
  post "login", to: "auth#login"

  # Albums
  resources :albums

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
