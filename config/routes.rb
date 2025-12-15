Rails.application.routes.draw do
  resources :albums
  root "albums#index"

  namespace :api do
    resources :albums
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
