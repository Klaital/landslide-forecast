class AddSumsToWeatherStationAlerts < ActiveRecord::Migration[5.0]
  def change
    change_table :weather_station_alerts do |t|
      t.float :old_sum
      t.float :recent_sum
    end
  end
end
