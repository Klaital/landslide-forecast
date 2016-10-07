namespace :db do
  desc "Download the latest precipitation data and update the DB"
  task :update, [:date] => [:environment] do |task, args|
    puts args.date
    require 'date'
    d = if args.date.nil?
          Date.today
        else
          Date.parse(args.date)
        end

    today = "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"

    puts "Working on date #{today}"
    data_dir = Rails.root.join('data')
    data_file = data_dir.join("#{today}.txt")
    unless File.exists?(data_file)
      data_url = "http://water.weather.gov/precip/p_download_new/#{d.year}/#{d.month.to_s.rjust(2,'0')}/#{d.day.to_s.rjust(2,'0')}/nws_precip_#{today}_nc.tar.gz"
      data_file = "./nws_precip_conus_#{today}.nc"
      latlong_converter = Rails.root.join('tools', 'nctoasc.exe').to_s

      puts "No data downloaded for #{today} yet. Downloading now from #{data_url}"
      puts `cd #{data_dir.to_s} && wget -O - #{data_url} | gunzip | tar -x #{data_file} && #{latlong_converter} #{today}`
    end

    puts "Update the DB"
    File.open(data_dir.join("#{today}.txt")) do |f|
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
        lat = tokens[3]
        long = tokens[4]
        precip = tokens[5]

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
  end
end
