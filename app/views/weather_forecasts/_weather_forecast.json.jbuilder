json.extract! weather_forecast, :id, :latitude, :longitude, :precip, :forecasted_on, :date, :created_at, :updated_at
json.url weather_forecast_url(weather_forecast, format: :json)