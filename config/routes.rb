Rails.application.routes.draw do
  root to: "dashboard#index"
  
  get  "/signin", to: "sessions#new"
  post "/signin", to: "sessions#create" 
  delete "/signout", to: "sessions#destroy"
  
  resources :users
  resources :meetings
  
  namespace :api, defaults: {format: 'json'}  do
    namespace :v1 do
      resources :conversations
    end
  end
end
