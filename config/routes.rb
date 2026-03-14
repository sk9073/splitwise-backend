Rails.application.routes.draw do
  get "/health", to: "health#index"

  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
    end
  end
end