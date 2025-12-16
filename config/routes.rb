Rails.application.routes.draw do
  namespace :api do
    resources :albums
  end

  root to: "api/albums#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
