require 'test_helper'

class WeatherStationTest < ActiveSupport::TestCase
  def setup
    @today = Date.today
    @recent_days = (1..3).collect {|i| @today - i}.collect {|d| "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"}
    @old_days = (4..18).collect {|i| @today - i}.collect {|d| "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"}

    @seatac = weather_stations(:seatac)
  end
  test "old weather reports should be correctly pulled via the shortcut" do
    assert_equal(20, @seatac.weather_reports.length)
    @recent_days.each do |d|
      r = @seatac.weather_reports.find_by(:date => d)
      assert_not_nil(r, "No Weather Report found for recent date #{d}")
    end
    @old_days.each do |d|
      r = @seatac.weather_reports.find_by(:date => d)
      assert_not_nil(r, "No Weather Report found for old date #{d}")
    end

    recent_reports = @seatac.recent_weather_reports
    assert_equal(3, recent_reports.length)
    old_reports = @seatac.old_weather_reports
    assert_equal(15, old_reports.length)
  end

  test "alert values should match expectations" do
    alert = @seatac.alert
    # I had to add the round(2) because recent_sum was coming back as 0.30000000000000004
    # Yay floating point math!
    assert_equal(0.3, alert.recent_sum.round(2))
    assert_equal(1.5, alert.old_sum.round(2))
    assert_equal(-2.195, alert.level.round(3))
    assert_equal(@today, alert.alert_for)
    assert_equal(@seatac.latitude, alert.latitude, "Alert latitude does not match the station")
    assert_equal(@seatac.longitude, alert.longitude, "Alert longitude does not match the station")
  end

  test "Darksky update should create historical weather reports" do
    user = User.new(email: 'darksky@example.org')
    user.password = user.password_confirmation = 'password'
    assert user.valid?
    user.save
    new_station = user.weather_stations.create(:name => 'Darksky Test Station', :latitude => 47.44888889, :longitude => -122.30944444)
    assert(new_station.valid?)
    new_station.save
    new_station.update_from_darksky
    assert(25, new_station.weather_reports.length)
    assert(3, new_station.recent_weather_reports.length)
    assert(15, new_station.old_weather_reports.length)

    # now try loading them from the DB directly
    s = WeatherStation.find_by(:name => 'Darksky Test Station')
    assert(25, s.weather_reports.length)
    assert(3, s.recent_weather_reports.length)
    assert(15, s.old_weather_reports.length)
  end
end
