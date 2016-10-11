class WeatherReport < ApplicationRecord
  def precip_inches
    return (self.precip / 254.0).round(4)
  end
  # def WeatherReport.alert_level(old_reports = {}, recent_reports = {})
  #   # Compute the timestamps for the required data points to compute this value
  #   old_days = (4..18).collect do |i|
  #     d = Date.today - i
  #   end.sort
  #   recent_days = (1..3).collect do |i|
  #     d = Date.today - i
  #   end.sort
  #
  #   # Validate whether the required data was given
  #   old_days.each do |d|
  #     return nil unless old_reports.has_key?(d)
  #   end
  #   recent_days.each do |d|
  #     return nil unless recent_reports.has_key?(d)
  #   end
  #
  #   # Compute the sum of each dataset
  #   old_sum = 0.0
  #   recent_sum = 0.0
  #   old_reports.each {|r| old_sum += r.precip}
  #   recent_reports.each {|r| recent_sum += r.precip}
  #
  #   old_sum_inches = old_sum * 254.0
  #   recent_sum_inches = recent_sum * 254.0
  #
  #   # Compute whether the coordinates place this station above the landslide threshhold
  #   threshold_level = 3.5 - 0.67 * old_sum_inches
  #   station_level   = recent_sum_inches
  #   alert_level_yesterday = station_level - threshold_level
  # end
end
