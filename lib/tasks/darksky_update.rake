namespace :db do
  namespace :update do
    desc "Fetch past precpitation data from Darksky."
    task :darksky, [:date, :lat, :long] => [:environment] do |task, args|
      require 'date'
      
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

      puts "Querying on dates: #{dates.join(', ')}"

      if args.lat.nil? || args.lat.to_s.strip == '' || args.long.nil? || args.long.to_s.strip == ''
        puts "Updating all stations"
        WeatherStation.find_each do |station|
          station.update_from_darksky(dates)
        end
      else
        puts "Updating selected station"
        WeatherStation.find_each(:longitude => args.lat.to_f, :latitude => args.long.to_f) do |station|
          station.update_from_darksky(dates)
        end
      end
    end
  end
end

