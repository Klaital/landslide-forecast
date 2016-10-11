class CreateWeatherStationAlerts < ActiveRecord::Migration[5.0]
  def change
    create_table :weather_station_alerts do |t|
      t.float :latitude
      t.float :longitude
      t.datetime :alert_for
      t.integer :level

      t.timestamps
    end
  end
end
