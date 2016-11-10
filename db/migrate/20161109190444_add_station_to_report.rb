class AddStationToReport < ActiveRecord::Migration[5.0]
  def change
    add_reference :weather_reports, :weather_station, foreign_key: true
  end
end
