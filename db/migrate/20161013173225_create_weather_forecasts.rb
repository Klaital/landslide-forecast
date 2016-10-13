class CreateWeatherForecasts < ActiveRecord::Migration[5.0]
  def change
    create_table :weather_forecasts do |t|
      t.float :latitude
      t.float :longitude
      t.float :precip
      t.datetime :forecasted_on
      t.datetime :date

      t.timestamps
    end
  end
end
