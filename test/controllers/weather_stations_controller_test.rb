require 'test_helper'

class WeatherStationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @weather_station = weather_stations(:seatac) # owned by user(:michael)
    @user_one = users(:one)
  end

  test "should get redirected from index to root when not logged in" do
    get weather_stations_url
    assert_redirected_to login_path
  end

  test "should get redirected from new to root when not logged in" do
    get new_weather_station_url
    assert_redirected_to login_path
  end

  test "should get redirected from show to root when not logged in" do
    get weather_station_url(@weather_station)
    assert_redirected_to login_path
  end

  test "should get error when creating a weather station while not logged in" do
    post weather_stations_url, params: { weather_station: {
                                          latitude: @weather_station.latitude,
                                          longitude: @weather_station.longitude,
                                          name: @weather_station.name,
                                          user_id: @weather_station.user_id} }
    assert_response :unauthorized
  end

  test "should create weather_station when logged in" do
    post login_path, params: { session: { email: 'michael@example.com', password: 'password-michael'}}
    assert_difference('WeatherStation.count') do
      post weather_stations_url, params: { weather_station: {
                                            latitude: @weather_station.latitude,
                                            longitude: @weather_station.longitude,
                                            name: @weather_station.name,
                                            user_id: @weather_station.user_id} }
    end

    assert_redirected_to weather_station_url(WeatherStation.last)
  end

  test "should show weather_station when logged in" do
    post login_path, params: { session: { email: 'michael@example.com', password: 'password-michael'}}

    get weather_station_url(@weather_station)
    assert_response :success
  end

  test "should get edit when logged in" do
    post login_path, params: { session: { email: 'michael@example.com', password: 'password-michael'}}
    get edit_weather_station_url(@weather_station)
    assert_response :success
  end
  test 'should get redirected to root from edit when not logged in' do
    get edit_weather_station_url(@weather_station)
    assert_redirected_to login_path
  end

  test "should update weather_station when logged in" do
    # Log in, then change the name of one of the user's weather stations
    post login_path, params: { session: { email: 'michael@example.com', password: 'password-michael'}}
    assert_not_equal('test station name', @weather_station.name)
    patch weather_station_url(@weather_station), params: { weather_station: {
                                                              latitude: @weather_station.latitude,
                                                              longitude: @weather_station.longitude,
                                                              name: 'test station name',
                                                              user_id: @weather_station.user_id } }
    assert_redirected_to weather_station_url(@weather_station)

    # Re-load that weather station, and check for the updated name
    s = WeatherStation.find(@weather_station.id)
    assert_equal('test station name', s.name)
  end

  test 'should get error when updating weather_station when not logged in' do
    delete logout_path
    follow_redirect!
    patch weather_station_url(@weather_station), params: { weather_station: {
        latitude: @weather_station.latitude,
        longitude: @weather_station.longitude,
        name: @weather_station.name,
        user_id: @weather_station.user_id } }
    assert_response :unauthorized
  end

  test "should get error when updating weather_station not your own" do
    # Login as user 'one', then try to update the provisioned weather station object, which belongs to user 'michael'
    post login_path, params: { session: { email: 'user-one@example.com', password: 'password-one'}}
    patch weather_station_url(@weather_station), params: { weather_station: {
        latitude: @weather_station.latitude,
        longitude: @weather_station.longitude,
        name: @weather_station.name,
        user_id: @weather_station.user_id } }
    assert_response :unauthorized
  end

  test "should fail to destroy weather_station when not logged in" do
    assert_no_difference('WeatherStation.count') do
      delete weather_station_url(@weather_station)
    end
    assert_response :unauthorized
  end

  test 'should destroy weather station when logged in' do
    post login_path, params: { session: { email: 'michael@example.com', password: 'password-michael'}}
    assert_difference('WeatherStation.count', -1) do
      delete weather_station_url(@weather_station)
    end

    assert_redirected_to '/weather_stations'
  end

  test 'should fail to destroy weather_station when logged in as a different user' do
    assert_no_difference('WeatherStation.count') do
      delete weather_station_url(@weather_station)
    end
    assert_response :unauthorized
  end

end
