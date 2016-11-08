class WeatherStation < ApplicationRecord
  # Query Darksky.net for each of the historical dates specified, 
  # plus the forecast, in order to compute the risk of landslides
  def update_from_darksky(historical_dates=[Date.today-1], forecast=true)
    darksky_secret = ApiKey.where(:service => 'Darksky').first.key
    hydra = Typhoeus::Hydra.new
    requests = Hash.new
    forecast_request = nil

    logger.debug("Updating Station #{name} for dates: #{historical_dates}")
    
    # Construct the HTTP requests to Darksky: one for each of the past days we care about, and one for today to get the forecast
    historical_dates.each do |d|
        endpoint = "https://api.darksky.net/forecast/#{darksky_secret}/#{self.latitude},#{self.longitude},#{d.to_s}"
        request = Typhoeus::Request.new(endpoint) 
        hydra.queue(request)
        requests[d] = request
    end
    forecast_request = Typhoeus::Request.new("https://api.darksky.net/forecast/#{darksky_secret}/#{self.latitude},#{self.longitude}")
    hydra.queue(forecast_request)

    # Run the whole lot of them!
    hydra.run

    # Parse out the observed precipitation from the historical queries
    reports = []
    requests.each_pair do |d, request|
        if request.response.timed_out?
            logger.error "Request to Darksky timed out: #{request}"
            next
        end
        if request.response.nil?
            logger.error "No response from Darksky for request #{request}"
            next
        end
        if request.response.code != 200
            logger.error "Unable to fetch weather data from #{request.base_url}: #{request.response.code} #{request.response.status_message}"
            next
        end

        # With error trapping done, let's parse the body and update the db with the report data.
        data = JSON.load(request.response.body)
        data['daily']['data'].each do |report|
            logger.debug(report)
            d = Time.at(report['time']).to_date
            datestamp = "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"
            logger.debug("Using timestamp #{datestamp}")
            # We want to update an existing row in place if we've previously computed one
            r = WeatherReport.find_or_create_by(
                :latitude => self.latitude,
                :longitude => self.longitude,
                :date => datestamp,
            )
            
            
            # TODO: multiply by the actual number of hours in the time period.
            precip = report['precipIntensity'] # This is in inches per hour
            logger.debug("Extracted precipitation report: #{precip}")
            r.precip = precip * 24.0
            logger.debug("Constructed WeatherReport: #{r}")
            logger.debug("Coordinates: #{r.latitude},#{r.longitude}")
            logger.debug("Datestamp: #{r.date}")
            logger.debug("Recorded Precip: #{r.precip}")
            
            r.save
            reports.push(r)
        end
    end

    # TODO: Add the forecast data as well
    logger.info("Parsing forecasts for station #{self}")
    logger.debug("Got response: #{forecast_request.response}")
    if forecast_request.response.timed_out?
      logger.error "Request to Darksky timed out: #{forecast_request}"
      return
    end
    if forecast_request.response.nil?
      logger.error "No response from Darksky for request #{forecast_request}"
      return
    end
    if forecast_request.response.code != 200
      logger.error "Unable to fetch weather data from #{forecast_request.base_url}: #{forecast_request.response.code} #{forecast_request.response.message}"
      return
    end

    logger.debug("Successful response from Darksky")
    data = JSON.load(forecast_request.response.body)
    data['daily']['data'].each do |report|
      logger.debug(report)
      d = Time.at(report['time']).to_date
      datestamp = "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"
      r = WeatherReport.find_or_create_by(
                :latitude => self.latitude,
                :longitude => self.longitude,
                :date => datestamp,
            )
      r.precip = report['precipIntensity'] * 24.0 # The Darksky report gives us inches per hour
      
      logger.debug("Created forecast object: #{r}")
      r.save
    end

    # TODO: add a column that we can record when this update was last run, for display on the webpage.
  end

  # Fetch the 18 days previous to the specified date, and use those records to
  # compute the risk of landslides for this station.
  def alert(today = Date.today)
    # Pull the previous 18 days' reports
    # These should all be loaded after running update_from_darksky
    old_days = (4..18).collect {|i| today - i}.collect {|d| "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"}
    recent_days = (1..3).collect {|i| today - i}.collect {|d| "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"}
    
    # Recent reports are the previous three days
    recent_precip = 0.0
    logger.info("Computing Recent Precip for Station #{self} on #{today}")
    WeatherReport.where(:latitude => self.latitude, :longitude => self.longitude, :date => recent_days).each do |report|
      recent_precip += report.precip_inches
    end
    logger.debug("Got #{recent_precip} inches of precipitation in the three prior days.")
    # Old reports are the 15 days prior to the 3 days' "recent reports". So, days d - 4 through d - 18
    old_precip = 0.0
    WeatherReport.where(:latitude => self.latitude, :longitude => self.longitude, :date => old_days).each do |report|
      old_precip += report.precip_inches
    end
    logger.debug("Got #{old_precip} inches of precipitation in the 15 days before that.")
    
    threshold_level = 3.5 - 0.67 * old_precip
    alert_level = recent_precip - threshold_level
    
    WeatherStationAlert.new(
      :latitude => self.latitude, :longitude => self.longitude, 
      :alert_for => today,
      :level => alert_level,
      :old_sum => old_precip,
      :recent_sum => recent_precip,
    ) 
  end
end
