require 'test_helper'

class WeatherReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @weather_report = weather_reports(:one)
  end

  test "should get index" do
    get weather_reports_url
    assert_response :success
  end

  test "should get new" do
    get new_weather_report_url
    assert_response :success
  end

  test "should create weather_report" do
    assert_difference('WeatherReport.count') do
      post weather_reports_url, params: { weather_report: { latitude: @weather_report.latitude, longitude: @weather_report.longitude, precip: @weather_report.precip } }
    end

    assert_redirected_to weather_report_url(WeatherReport.last)
  end

  test "should show weather_report" do
    get weather_report_url(@weather_report)
    assert_response :success
  end

  test "should get edit" do
    get edit_weather_report_url(@weather_report)
    assert_response :success
  end

  test "should update weather_report" do
    patch weather_report_url(@weather_report), params: { weather_report: { latitude: @weather_report.latitude, longitude: @weather_report.longitude, precip: @weather_report.precip } }
    assert_redirected_to weather_report_url(@weather_report)
  end

  test "should destroy weather_report" do
    assert_difference('WeatherReport.count', -1) do
      delete weather_report_url(@weather_report)
    end

    assert_redirected_to weather_reports_url
  end
end
