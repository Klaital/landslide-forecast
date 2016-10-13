class WeatherForecast < ApplicationRecord
  def precip_inches
    return (self.precip / 254.0).round(4)
  end
end
