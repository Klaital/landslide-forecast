class CreateWeatherStations < ActiveRecord::Migration[5.0]
  def change
    create_table :weather_stations do |t|
      t.float :latitude
      t.float :longitude
      t.string :name

      t.timestamps
    end
  end
end
