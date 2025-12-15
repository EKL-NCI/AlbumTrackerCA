Rails.application.routes.draw do
  namespace :api do
    resources :albums
  end

  direct :rails_blob do |blob, options|
    route_for(:rails_blob, blob, options)
  end

  root to: "api/albums#index"
  get "up" => "rails/health#show", as: :rails_health_check
end