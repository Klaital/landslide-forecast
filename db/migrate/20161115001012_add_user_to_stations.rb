class AddUserToStations < ActiveRecord::Migration[5.0]
  def change
    add_reference :weather_stations, :user, foreign_key: true
  end
end
