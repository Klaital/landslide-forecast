namespace :db do
  desc "Aggregate the data for the last 18 days to generate alert levels"
  task :alerts, [:lat, :long] => [:environment, "db:update"] do |task, args|
    # Now that all of the relevant data is loaded into the DB (via rake dependency),
    # we should process all of the stations for alerts


    # Decide which stations to update
    stations = if args.lat.nil? || args.long.nil?
                 puts "No station specified, updating all..."
                 WeatherStationAlert.all
               else
                 a = WeatherStationAlert.where(:latitude => args.lat, :longitude => args.long)
                 if a.length == 0
                   [WeatherStationAlert.new(:latitude => args.lat, :longitude => args.long)]
                 else
                   a
                 end
               end

    puts "Got #{stations.length} stations to update"

    old_dates = (4..18).collect {|i| d = Date.today - i; "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"}
    recent_dates = (1..3).collect {|i| d = Date.today - i; "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"}

    stations.each do |s|
      station_start = Time.now

      old_sum = 0.0
      recent_sum = 0.0

      old_reports = WeatherReport.where(:date => old_dates, :latitude => s.latitude, :longitude => s.longitude)
      print "Found #{old_reports.count} old reports "
      old_reports.each {|r| old_sum += r.precip}
      puts " for #{old_sum / 10} mm of precipitation"
      recent_reports = WeatherReport.where(:date => recent_dates, :latitude => s.latitude, :longitude => s.longitude)
      print "Found #{recent_reports.count} recent reports"
      recent_reports.each {|r| recent_sum += r.precip}
      puts " for #{recent_sum / 10} mm of precipitation"

      old_sum_inches = old_sum / 254.0
      recent_sum_inches = recent_sum / 254.0

      # Compute whether the coordinates place this station above the landslide threshhold
      threshold_level = 3.5 - 0.67 * old_sum_inches
      puts "Threshold level: #{threshold_level}"
      station_level   = recent_sum_inches
      puts "Station level: #{station_level}"
      alert_level_yesterday = station_level - threshold_level

      s.level = alert_level_yesterday
      s.old_sum = old_sum
      s.recent_sum = recent_sum
      s.alert_for = Date.today - 1
      s.save
      puts "Station #{args.lat},#{args.long} updated in #{((Time.now - station_start).to_f * 1000).round} ms"
    end
  end
end
