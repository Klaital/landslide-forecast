class ChangeAlertLevelToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column :weather_station_alerts, :level, :float
  end
end
