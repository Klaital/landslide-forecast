require 'test_helper'

class WeatherForecastsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @weather_forecast = weather_forecasts(:one)
  end

  test "should get index" do
    get weather_forecasts_url
    assert_response :success
  end

  test "should get new" do
    get new_weather_forecast_url
    assert_response :success
  end

  test "should create weather_forecast" do
    assert_difference('WeatherForecast.count') do
      post weather_forecasts_url, params: { weather_forecast: { date: @weather_forecast.date, forecasted_on: @weather_forecast.forecasted_on, latitude: @weather_forecast.latitude, longitude: @weather_forecast.longitude, precip: @weather_forecast.precip } }
    end

    assert_redirected_to weather_forecast_url(WeatherForecast.last)
  end

  test "should show weather_forecast" do
    get weather_forecast_url(@weather_forecast)
    assert_response :success
  end

  test "should get edit" do
    get edit_weather_forecast_url(@weather_forecast)
    assert_response :success
  end

  test "should update weather_forecast" do
    patch weather_forecast_url(@weather_forecast), params: { weather_forecast: { date: @weather_forecast.date, forecasted_on: @weather_forecast.forecasted_on, latitude: @weather_forecast.latitude, longitude: @weather_forecast.longitude, precip: @weather_forecast.precip } }
    assert_redirected_to weather_forecast_url(@weather_forecast)
  end

  test "should destroy weather_forecast" do
    assert_difference('WeatherForecast.count', -1) do
      delete weather_forecast_url(@weather_forecast)
    end

    assert_redirected_to weather_forecasts_url
  end
end
