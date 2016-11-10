require 'test_helper'

class WeatherStationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @weather_station = weather_stations(:seatac)
  end

  test "should get index" do
    get weather_stations_url
    assert_response :success
  end

  test "should get new" do
    get new_weather_station_url
    assert_response :success
  end

  test "should create weather_station" do
    assert_difference('WeatherStation.count') do
      post weather_stations_url, params: { weather_station: { latitude: @weather_station.latitude, longitude: @weather_station.longitude, name: @weather_station.name } }
    end

    assert_redirected_to weather_station_url(WeatherStation.last)
  end

  test "should show weather_station" do
    get weather_station_url(@weather_station)
    assert_response :success
  end

  test "should get edit" do
    get edit_weather_station_url(@weather_station)
    assert_response :success
  end

  test "should update weather_station" do
    patch weather_station_url(@weather_station), params: { weather_station: { latitude: @weather_station.latitude, longitude: @weather_station.longitude, name: @weather_station.name } }
    assert_redirected_to weather_station_url(@weather_station)
  end

  test "should destroy weather_station" do
    assert_difference('WeatherStation.count', -1) do
      delete weather_station_url(@weather_station)
    end

    assert_redirected_to weather_stations_url
  end
end
