Rails.application.routes.draw do
  resources :weather_stations
  resources :weather_reports
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
