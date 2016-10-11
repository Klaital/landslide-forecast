Rails.application.routes.draw do
  resources :weather_station_alerts
  resources :weather_stations
  resources :weather_reports

  root 'weather_stations#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
