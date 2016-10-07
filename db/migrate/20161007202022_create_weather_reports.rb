class CreateWeatherReports < ActiveRecord::Migration[5.0]
  def change
    create_table :weather_reports do |t|
      t.float :latitude
      t.float :longitude
      t.float :precip

      t.timestamps
    end
  end
end
