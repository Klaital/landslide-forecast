Rails.application.routes.draw do
  get 'static_pages/about'
  get 'static_pages/contact'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'

  resources :weather_forecasts
  resources :weather_station_alerts
  resources :weather_stations
  resources :weather_reports

  root 'weather_stations#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
