require 'test_helper'

class WeatherStationAlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @weather_station_alert = weather_station_alerts(:one)
  end

  test "should get index" do
    get weather_station_alerts_url
    assert_response :success
  end

  test "should get new" do
    get new_weather_station_alert_url
    assert_response :success
  end

  test "should create weather_station_alert" do
    assert_difference('WeatherStationAlert.count') do
      post weather_station_alerts_url, params: { weather_station_alert: { alert_for: @weather_station_alert.alert_for, latitude: @weather_station_alert.latitude, level: @weather_station_alert.level, longitude: @weather_station_alert.longitude } }
    end

    assert_redirected_to weather_station_alert_url(WeatherStationAlert.last)
  end

  test "should show weather_station_alert" do
    get weather_station_alert_url(@weather_station_alert)
    assert_response :success
  end

  test "should get edit" do
    get edit_weather_station_alert_url(@weather_station_alert)
    assert_response :success
  end

  test "should update weather_station_alert" do
    patch weather_station_alert_url(@weather_station_alert), params: { weather_station_alert: { alert_for: @weather_station_alert.alert_for, latitude: @weather_station_alert.latitude, level: @weather_station_alert.level, longitude: @weather_station_alert.longitude } }
    assert_redirected_to weather_station_alert_url(@weather_station_alert)
  end

  test "should destroy weather_station_alert" do
    assert_difference('WeatherStationAlert.count', -1) do
      delete weather_station_alert_url(@weather_station_alert)
    end

    assert_redirected_to weather_station_alerts_url
  end
end
