class WeatherStationsController < ApplicationController
  before_action :set_weather_station, only: [:show, :edit, :update, :destroy]

  # GET /weather_stations
  # GET /weather_stations.json
  def index
    @weather_stations = WeatherStation.all
  end

  # GET /weather_stations/1
  # GET /weather_stations/1.json
  def show
    @weather_reports = WeatherReport.where(:latitude => @weather_station.latitude, :longitude => @weather_station.longitude)


    @old_days = (4..15).collect do |i|
      d = Date.today - i
      "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"
    end.sort

    @old_reports = {}
    @old_sum = 0.0
    @old_days.each do |d|
      reports = WeatherReport.where(:latitude => @weather_station.latitude, :longitude => @weather_station.longitude, :date => d)
      if reports.length > 0
        r = reports.first
        @old_reports[d] = r
        @old_sum += r.precip
      end
    end


    @recent_days = (1..3).collect do |i|
      d = Date.today - i
      "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"
    end.sort

    @recent_reports = {}
    @recent_sum = 0.0
    @recent_days.each do |d|
      reports = WeatherReport.where(:latitude => @weather_station.latitude, :longitude => @weather_station.longitude, :date => d)
      if reports.length > 0
        @recent_reports[d] = reports.first
        @recent_sum += @recent_reports[d].precip
      end
    end

    # landslide threshhold line: y = 3.5 - 0.67x
    # where y := @old_sum, and x := @recent_sum
    # Thus, for the station, if 3.5 - 0.67 * @recent_sum < @old_sum, then fire the alert!
    @alert_yesterday = (3.5 - 0.67 * @recent_sum < @old_sum)
    if @alert_yesterday
      flash[:alert] = "As of yesterday's rainfall, station #{@weather_station.name} is at risk for landslides!!"
    end
  end

  # GET /weather_stations/new
  def new
    @weather_station = WeatherStation.new
  end

  # GET /weather_stations/1/edit
  def edit
  end

  # POST /weather_stations
  # POST /weather_stations.json
  def create
    @weather_station = WeatherStation.new(weather_station_params)

    respond_to do |format|
      if @weather_station.save
        format.html { redirect_to @weather_station, notice: 'Weather station was successfully created.' }
        format.json { render :show, status: :created, location: @weather_station }
      else
        format.html { render :new }
        format.json { render json: @weather_station.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /weather_stations/1
  # PATCH/PUT /weather_stations/1.json
  def update
    # respond_to do |format|
    #   if @weather_station.update(weather_station_params)
    #     format.html { redirect_to @weather_station, notice: 'Weather station was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @weather_station }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @weather_station.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /weather_stations/1
  # DELETE /weather_stations/1.json
  def destroy
    # @weather_station.destroy
    # respond_to do |format|
    #   format.html { redirect_to weather_stations_url, notice: 'Weather station was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weather_station
      @weather_station = WeatherStation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def weather_station_params
      params.require(:weather_station).permit(:latitude, :longitude, :name)
    end
end
