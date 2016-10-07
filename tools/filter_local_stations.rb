require 'optparse'
require 'date'

latitude_bounds = {
  :north => 48.997222,
  :south => 45.559167,
}
longitude_bounds = {
  :east => -116.921431,
  :west => -124.740328,
}

# Default to processing yesterday's data
d = Date.today
date_to_process = "#{d.year}#{d.month.to_s.ljust(2,'0')}#{d.day.to_s.ljust(2,'0')}"

# By default, include all precip values
minimum_precip = -4.0

# TODO: add cli options parsing
OptionParser.new do |o|
  o.banner = "Read the ASCII version of the NWS Precipitation data file for a particular day, and record the rows that fall within specified geographical bounds."
  
  o.on('-n', '--north LAT', 'Northernmost latitude to consider. South is negative.') do |l|
    latitude_bounds[:north] = l.to_f
  end
  
  o.on('-s', '--south LAT', 'Southernmost latitude to consider. South is negative.') do |l|
    latitude_bounds[:south] = l.to_f
  end
  
  o.on('-e', '--east LONG', 'Easternmost longitude to consider. West is negative.') do |l|
    longitude_bounds[:east] = l.to_f
  end
  
  o.on('-w', '--west LONG', 'Westernmost longitude to consider. West is negative.') do |l|
    longitude_bounds[:west] = l.to_f
  end
  
  o.on('-d', '--date YYYYMMDD', 'Specify the date for the data to be processed.') do |d|
    date_to_process = d.strip
  end
  
  o.on('--min PRECIP', 'Minimum value of precipitation to be worth considering. Use this to filter out the error rows: -1 for no data, -2 for missing data.') do |p|
    minimum_precip = p.to_f
  end
  
  o.on_tail('-h', '--help', 'Display this help output.') do
    puts o.to_s
    exit(0)
  end
end.parse!

# TODO: automatically download yesterday's file in another script via cron

def filter_line(line, latitude_bounds, longitude_bounds, minimum_precip=-4)
  # Rewrite the header to reflect the new schema
  return "lat,long,precip" unless line =~ /^\d/

  # Extract the three columns we are interested in: latitude, longitude, and precipitation amount.
  # Note: the precip is recorded in hundredths of a millimeter. "-1" means no data, and "-2" means missing data.
  tokens = line.split(',')
  lat = tokens[3]
  long = tokens[4]
  precip = tokens[5]

  # Validate that the row had data

  lat = lat.to_f
  long = long.to_f
  precip = precip.to_f

  # Check whether the coordinates fall within the specified bounds
  if lat >= latitude_bounds[:south] && lat <= latitude_bounds[:north] &&
      long <= longitude_bounds[:east] && long >= longitude_bounds[:west] &&
      minimum_precip <= precip
    # Use the original strings to eliminate rounding error from accumulating.
    return "#{tokens[3]},#{tokens[4]},#{tokens[5]}"
  end

  # Data fell out of bounds
  return nil
end



###################
###### MAIN #######
###################

file = File.open("#{date_to_process}.txt", 'r')
while(s=file.gets)
  line = filter_line(s.strip, latitude_bounds, longitude_bounds, minimum_precip)
  puts line unless line.nil?
end
file.close
