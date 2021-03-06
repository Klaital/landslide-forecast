Rails.application.routes.draw do

  # Static Pages
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'

  # User Handling
  resources :users
  get '/signup', to: 'users#new'
  post '/signup',  to: 'users#create'
  get 'sessions/new'

  get '/login',    to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :weather_stations
  resources :weather_reports

  root 'weather_stations#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
