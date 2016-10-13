namespace :db do
  namespace :darksky do
    desc "Return a list of weather stations known near the given position. The Radius should be specified in meters."
    task :forecasts, [:lat, :long] => [:environment] do |task, args|
      require 'date'
      require 'set'
      require 'net/http'
      require 'json'

      # Aggregate all of the station coordinates so that we can multithread the
      # Darksky API requests.
      station_coords = Set.new
      if args.lat.nil? || args.long.nil? 
        WeatherStation.find_each do |station|
          station_coords.add({:lat => station.latitude, :lon => station.longitude})
        end
      else
        station_coords.add({:lat => args.lat.to_f, :lon => args.long.to_f})
      end


      darksky_secret = ApiKey.where(:service => 'Darksky').first.key
      station_coords.each do |point|
        endpoint = "https://api.darksky.net/forecast/#{darksky_secret}/#{point[:lat]},#{point[:lon]}"
        uri = URI.parse(endpoint)
        puts "Calling Darksky: #{endpoint}"
        response = nil
        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Get.new uri
          response = http.request request
        end
        puts response

        if !response.nil? && response.code == 200
          data = JSON.load(response.body)
          data['daily'].each do |forecast|
            f = WeatherForecast.new(
                :latitude => point[:lat],
                :longitude => point[:lon],
                :precip => forecast['precipIntensityMax'],
                :forecasted_on => Date.today,
                :date => Time.at(forecast['time']).to_date
            )
            f.save
            puts "[SUCCESS] Created weather forecast at #{f.latitude},#{f.longitude} for #{f.date}: #{f.precip}"
          end
        else
          puts "[ERROR] Unable to fetch weather data from #{endpoint}: #{response.code} #{response.message}"
        end
      end
    end
  end
end

