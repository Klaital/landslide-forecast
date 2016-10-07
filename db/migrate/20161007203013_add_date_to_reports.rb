class AddDateToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :weather_reports, :date, :string
    add_index :weather_reports, :date
    add_index :weather_reports, :latitude
    add_index :weather_reports, :longitude
  end
end
