json.extract! weather_station, :id, :latitude, :longitude, :name, :created_at, :updated_at
json.url weather_station_url(weather_station, format: :json)