class WeatherStationAlertsController < ApplicationController
  before_action :set_weather_station_alert, only: [:show, :edit, :update, :destroy]

  # GET /weather_station_alerts
  # GET /weather_station_alerts.json
  def index
    @weather_station_alerts = WeatherStationAlert.all
  end

  # GET /weather_station_alerts/1
  # GET /weather_station_alerts/1.json
  def show
  end

  # GET /weather_station_alerts/new
  def new
    # @weather_station_alert = WeatherStationAlert.new
  end

  # GET /weather_station_alerts/1/edit
  def edit
  end

  # POST /weather_station_alerts
  # POST /weather_station_alerts.json
  def create
    # @weather_station_alert = WeatherStationAlert.new(weather_station_alert_params)
    #
    # respond_to do |format|
    #   if @weather_station_alert.save
    #     format.html { redirect_to @weather_station_alert, notice: 'Weather station alert was successfully created.' }
    #     format.json { render :show, status: :created, location: @weather_station_alert }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @weather_station_alert.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /weather_station_alerts/1
  # PATCH/PUT /weather_station_alerts/1.json
  def update
    # respond_to do |format|
    #   if @weather_station_alert.update(weather_station_alert_params)
    #     format.html { redirect_to @weather_station_alert, notice: 'Weather station alert was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @weather_station_alert }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @weather_station_alert.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /weather_station_alerts/1
  # DELETE /weather_station_alerts/1.json
  def destroy
    # @weather_station_alert.destroy
    # respond_to do |format|
    #   format.html { redirect_to weather_station_alerts_url, notice: 'Weather station alert was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weather_station_alert
      @weather_station_alert = WeatherStationAlert.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def weather_station_alert_params
      params.require(:weather_station_alert).permit(:latitude, :longitude, :alert_for, :level)
    end
end
