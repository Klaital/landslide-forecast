namespace :db do
  namespace :darksky do
    desc "Fetch past precpitation data from Darksky."
    task :history, [:lat, :long, :date] => [:environment] do |task, args|
      require 'date'
      require 'set'
      require 'net/http'
      require 'json'

      dates = if args.date.nil?
        # Default to looking up yesterday's report
        ["#{(Date.today - 1).to_s}T00:00:00"]
      else
        # Provide a shortcut to fetching the last 18 days' reports, useful for initializing the database.
        if args.date == 'all'
          (1..18).collect {|i| "#{(Date.today - i).to_s}T00:00:00"}
        else
          # Provide the ability to fetch a single day's report. Useful for debugging.
          ["#{Date.parse(args.date).to_s}T00:00:00"]
        end
      end

      # Aggregate all of the station coordinate / date string pairs so that we can
      #  multithread the Darksky API requests.
      station_coords = Set.new
      if args.lat.nil? || args.long.nil? 
        WeatherStation.find_each do |station|
          station_coords.add({:lat => station.latitude, :lon => station.longitude})
        end
      else
        station_coords.add({:lat => args.lat.to_f, :lon => args.long.to_f})
      end


      darksky_secret = ApiKey.where(:service => 'Darksky').first.key
      hydra = Typhoeus::Hydra.new
      requests = Set.new
      station_coords.each do |point|
        dates.each do |d|
          endpoint = "https://api.darksky.net/forecast/#{darksky_secret}/#{point[:lat]},#{point[:lon]},#{(Date.today-18).to_s}T00:00:00"
          puts "Queueing #{endpoint}"
          request =   Typhoeus::Request.new(endpoint)
          requests.add(request)
          hydra.queue(request)
        end
      end

      puts "Starting queries..."
      hydra.run
      requests.each do |request|
        if request.response.timed_out?
          puts "[ERROR] Request to Darksky timed out"
          next
        end
        if request.response.nil?
          puts "[ERROR] No response from Darksky"
          next
        end
        if request.response.code != 200
          puts "[ERROR] Unable to fetch weather data from #{request.base_url}: #{request.response.code} #{request.response.message}"
          next
        end

        # With error trapping done, let's parse the body and update the db with the report data.
        data = JSON.load(request.response.body)
        data['daily']['data'].each do |report|
          t= Time.at(report['time'].to_i)
          r = WeatherReport.new(
              :latitude => point[:lat],
              :longitude => point[:lon],
              :precip => forecast['precipIntensityMax'],
              :date => "#{t.year}#{t.month.to_s.rjust(2,'0')}#{t.day.to_s.rjust(2,'0')}",
          )
          r.save
          puts "[SUCCESS] Created weather report at #{r.latitude},#{r.longitude} for #{r.date}: #{r.precip}"
        end
      end
    end
  end
end

