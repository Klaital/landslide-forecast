class WeatherReport < ApplicationRecord
  belongs_to :weather_station

  def precip_inches
    # Darksky reports precip in inches by default for US locations
    return self.precip
  end
end
