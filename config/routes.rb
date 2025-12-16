Rails.application.routes.draw do
  rails_blob_routes

  namespace :api do
    resources :albums
  end

  root to: "api/albums#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
