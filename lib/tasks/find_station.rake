desc "Return a list of weather stations known near the given position. The Radius should be specified in meters."
task :find_station, [:lat, :long, :radius] => [:environment] do |task, args|
  # Set defaults
  radius_meters = if args.radius.nil?
                    5000
                  elsif args.radius.downcase == 'nearest'
                    150000
                  else
                    args.radius.to_i
                  end

  home_station  = WeatherStationAlert.new(:latitude => args.lat,:longitude =>args.long)

  def distance_cosines(station1, station2)
    lat1 = station1.latitude
    lat2 = station2.latitude
    lon1 = station1.longitude
    lon2 = station2.longitude
    Math.acos( Math.sin(lat1*Math::PI/180) * Math.sin(lat2*Math::PI/180) +
                   Math.cos(lat1*Math::PI/180) * Math.cos(lat2*Math::PI/180) *
                   Math.cos(lon2*Math::PI/180-lon1*Math::PI/180)
             ) * 6371000
  end

  near_stations = Hash.new
  stations = Set.new
  all_stations = WeatherStationAlert.all

  all_stations.each do |s|
    print "Checking station #{s.latitude},#{s.longitude}..."
    stations.add("#{s.latitude},#{s.longitude}")
    distance = distance_cosines(s, home_station)
    print " #{distance} m. "
    if distance <= radius_meters
      station_id = "#{s.latitude},#{s.longitude}"
      if near_stations.has_key?(station_id)
        near_stations[station_id] = distance if distance < near_stations[station_id]
      else
        near_stations[station_id] = distance
      end

      puts "\t[KEEP]"
    else
      puts "\t[FAIL]"
    end
  end

  puts "Found #{near_stations.keys.length}/#{stations.length} stations within #{radius_meters} meters of the target."
  if args.radius.downcase == 'nearest' && near_stations.length > 0
    nearest_distance = near_stations.values.sort.first
    puts "#{near_stations.invert[nearest_distance]}, #{nearest_distance} meters"
  elsif near_stations.length > 0
    near_stations.each_pair {|s,d| puts "#{s}, #{d} meters"}
  end

end

