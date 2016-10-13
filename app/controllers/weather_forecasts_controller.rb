class WeatherForecastsController < ApplicationController
  before_action :set_weather_forecast, only: [:show, :edit, :update, :destroy]

  # GET /weather_forecasts
  # GET /weather_forecasts.json
  def index
    @weather_forecasts = WeatherForecast.all
  end

  # GET /weather_forecasts/1
  # GET /weather_forecasts/1.json
  def show
  end

  # GET /weather_forecasts/new
  def new
    @weather_forecast = WeatherForecast.new
  end

  # GET /weather_forecasts/1/edit
  def edit
  end

  # POST /weather_forecasts
  # POST /weather_forecasts.json
  def create
    # @weather_forecast = WeatherForecast.new(weather_forecast_params)
    #
    # respond_to do |format|
    #   if @weather_forecast.save
    #     format.html { redirect_to @weather_forecast, notice: 'Weather forecast was successfully created.' }
    #     format.json { render :show, status: :created, location: @weather_forecast }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @weather_forecast.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /weather_forecasts/1
  # PATCH/PUT /weather_forecasts/1.json
  def update
    # respond_to do |format|
    #   if @weather_forecast.update(weather_forecast_params)
    #     format.html { redirect_to @weather_forecast, notice: 'Weather forecast was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @weather_forecast }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @weather_forecast.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /weather_forecasts/1
  # DELETE /weather_forecasts/1.json
  def destroy
    # @weather_forecast.destroy
    # respond_to do |format|
    #   format.html { redirect_to weather_forecasts_url, notice: 'Weather forecast was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weather_forecast
      @weather_forecast = WeatherForecast.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def weather_forecast_params
      params.require(:weather_forecast).permit(:latitude, :longitude, :precip, :forecasted_on, :date)
    end
end
