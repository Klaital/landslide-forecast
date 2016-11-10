class WeatherStationAlert < ApplicationRecord
  def level_description
    if -3.5 == level.round(2)
      'Minimal Risk (no precip in last 18 days)'
    elsif level < 0
      'Low Risk'
    else
      'Landslide Warning!'
    end
  end
end
