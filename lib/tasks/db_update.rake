namespace :db do
  desc "Download the latest precipitation data and update the DB"
  task :update, [:date] => [:environment] do |task, args|

    require 'date'
    require 'set'

    # Determine which data files we need to process today. By default,
    # we need to process everything from yesterday back through eighteen days ago.
    dates = if args.date.nil?
          (1..18).collect {|i| Date.today - i}
        else
          [Date.parse(args.date)]
        end

    # Keep track of each unique lat/long pair representing a weather station.
    # Once the DB load is complete, we will process each station's risk factor.
    stations = Set.new

    # For each date, download, parse and update the database with all precipitation
    # reports that fall within certain geographical constraints (WA state for now).
    #
    # If the intermediary files are still found, we should skip step as possible.
    # This will minimize load on the NOAA fileservers and optimize the runtime of
    # the alerts generation.
    dates.each do |d|
      today = "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"

      puts "Working on date #{today}"
      data_dir = Rails.root.join('data')
      converted_file = data_dir.join("#{today}.txt")

      # Reduce our workload for repeat days.
      if File.exists?("#{converted_file.to_s}.done")
        puts "Data processing already done for #{today}. Skipping to next day..."
        next
      end

      data_file = data_dir.join("nws_precip_conus_#{today}.nc").to_s
      unless File.exists?(data_file)
        data_url = "http://water.weather.gov/precip/p_download_new/#{d.year}/#{d.month.to_s.rjust(2,'0')}/#{d.day.to_s.rjust(2,'0')}/nws_precip_#{today}_nc.tar.gz"
        latlong_converter = Rails.root.join('tools', 'nctoasc.exe').to_s

        puts "No data downloaded for #{today} yet. Downloading now from #{data_url}"
        puts `cd #{data_dir.to_s} && wget -O - #{data_url} | gunzip | tar -x #{data_file}`
        puts "Converting to Lat/Long from original NC file's polar coordinates."
        puts `cd #{data_dir.to_s} && #{latlong_converter} #{today}`
      end

      puts "Update the DB, saving results to a file as we go"
      File.open(converted_file) do |f|
        skipped = 0
        created = 0
        line_count = 0
        start_time = Time.now
        while(s=f.gets)
          line_count += 1
          # Skip the header row
          next if s =~ /^"id"/

          # Extract the three columns we are interested in: latitude, longitude, and precipitation amount.
          # Note: the precip is recorded in hundredths of a millimeter. "-1" means no data, and "-2" means missing data.
          tokens = s.split(',')
          lat = tokens[4]
          long = tokens[5]
          precip = tokens[6]

          # Validate data was found in all columns
          if lat.nil? || long.nil? || precip.nil?
  #          warn "Skipping line due to insufficient data "
            skipped += 1
            next
          end

          precip = precip.to_f

          # Skip entries with no data
          if precip < 0.0
  #          warn "Skipping line due to precip value of #{precip}"
            skipped += 1
            next
          end

          # TODO: make the lat/long bounds read from the CLI, or remove the restriction outright
          latitude_bounds = {
              :north => 48.997222,
              :south => 45.559167,
          }
          longitude_bounds = {
              :east => -116.921431,
              :west => -124.740328,
          }

          lat = lat.to_f
          long = long.to_f

          # Check whether the coordinates fall within the specified bounds
          unless lat >= latitude_bounds[:south] && lat <= latitude_bounds[:north] &&
              long <= longitude_bounds[:east] && long >= longitude_bounds[:west]
            skipped += 1
            next
          end


          # Save the station's coordinates for later alert processing
          stations.add("#{tokens[4].strip},#{tokens[5].strip}")
          update_start = Time.now
          print "[#{today}:#{line_count}] Checking for existing record... "
          report = WeatherReport.where(:latitude => lat.to_f, :longitude => long.to_f, :date => today)
          if report.length == 0
            print "Adding new record to DB"
            report = WeatherReport.new(:latitude => lat.to_f, :longitude => long.to_f, :precip => precip, :date => today)
          else
            print "Updating existing record"
            report = report.first
            report.precip = precip
          end

          report.save
          runtime = ((Time.now - update_start) * 1000).to_f.round
          puts " (#{runtime} ms)"
          created += 1

        end

        runtime = (Time.now - start_time).to_f.round
        puts "Created #{created} new, skipped #{skipped} rows, in #{runtime} seconds"
      end

      `touch #{converted_file.to_s}.done`
    end

    # Now that all of the relevant data is loaded into the DB, we should process all of the stations for alerts
    puts "Generating alerts for #{stations.length} weather stations..."
    alerts_start = Time.now
    stations.each do |latlong|
      puts "> Updating station #{latlong} now..."
      lat, long = latlong.split(',').collect {|i| i.to_f}
      task("db:alerts").invoke(lat, long)
    end
    puts "Alerts completed in #{(Time.now - alerts_start).to_f.round} seconds"
  end
end
