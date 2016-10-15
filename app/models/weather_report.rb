class WeatherReport < ApplicationRecord
  def precip_inches
    # Darksky reports precip in inches by default for US locations
    return self.precip
  end
end
