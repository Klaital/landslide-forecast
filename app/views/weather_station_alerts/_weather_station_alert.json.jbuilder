json.extract! weather_station_alert, :id, :latitude, :longitude, :alert_for, :level, :created_at, :updated_at
json.url weather_station_alert_url(weather_station_alert, format: :json)