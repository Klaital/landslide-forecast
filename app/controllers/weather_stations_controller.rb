class WeatherStationsController < ApplicationController
  before_action :set_weather_station, only: [:show, :edit, :update, :destroy]

  # GET /weather_stations
  # GET /weather_stations.json
  def index
    unless logged_in?
      flash.now[:warning] = 'Please log in to view your weather stations'
      redirect_to login_path
    end

    @weather_stations = WeatherStation.all
  end

  # GET /weather_stations/1
  # GET /weather_stations/1.json
  def show
    unless logged_in? && current_user.id == @weather_station.user.id
      flash.now[:warning] = 'Please log in to view your weather stations'
      redirect_to login_path and return
    end

    @weather_reports = @weather_station.weather_reports.all

    @old_days = (4..15).collect do |i|
      d = Date.today - i
      "#{d.year}#{d.month.to_s.rjust(2,'0')}#{d.day.to_s.rjust(2,'0')}"
    end.sort

    @old_reports = {}
    @old_sum = 0.0
    @old_days.each do |d|
      reports = @weather_station.weather_reports.where(:date => d)
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
      reports = @weather_station.weather_reports.where(:date => d)
      if reports.length > 0
        @recent_reports[d] = reports.first
        @recent_sum += @recent_reports[d].precip
      end
    end

    @chart_data = [
        {
            :name => 'Alert Level',
            :data => @alert_forecasts.map {|date, alert| [date, alert.level]}
        },
        {
            :name => 'Precipitation',
            :data => []
        }
    ]

    @weather_reports.each do |r|
      @chart_data[1][:data].push [ Date.parse(r.date), r.precip ] 
    end

    if @alert_today.level > 0
      flash[:alert] = "As of yesterday's rainfall, station #{@weather_station.name} is at risk for landslides!!"
    else
      flash[:notice] = "This station is at low landslide risk"
    end
  end

  # GET /weather_stations/new
  def new
    unless logged_in?
      flash.now[:warning] = 'Please log in to view your weather stations'
      redirect_to login_path and return
    end
    @weather_station = current_user.weather_statiosn.create
  end

  # GET /weather_stations/1/edit
  def edit
    unless logged_in? && current_user.id == @weather_station.user.id
      flash.now[:warning] = 'Please log in to view your weather stations'
      redirect_to login_path
    end
  end

  # POST /weather_stations
  # POST /weather_stations.json
  def create
    unless logged_in?
      render :file => 'public/401', :status => :unauthorized, :layout => false and return
    end

    @user = User.find(weather_station_params[:user_id])
    @weather_station = @user.weather_stations.create(weather_station_params)

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
    unless logged_in? && current_user.id == @weather_station.user.id
      # debugger
      render :file => 'public/401', :status => :unauthorized, :layout => false and return
    end

    respond_to do |format|
      if @weather_station.update(weather_station_params)
        format.html { redirect_to @weather_station, notice: 'Weather station was successfully updated.' }
        format.json { render :show, status: :ok, location: @weather_station }
      else
        format.html { render :edit }
        format.json { render json: @weather_station.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weather_stations/1
  # DELETE /weather_stations/1.json
  def destroy
    unless logged_in? && current_user.id == @weather_station.user.id
      render :file => 'public/401', :status => :unauthorized, :layout => false and return
    end

    @weather_station.destroy
    respond_to do |format|
      format.html { redirect_to weather_stations_url, notice: 'Weather station was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weather_station
      if logged_in?
        begin
          @weather_station = current_user.weather_stations.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render :file => 'public/401', :status => :unauthorized, :layout => false and return
        end
        @alert_today = @weather_station.alert
        @alert_forecasts = {}
        (0..7).each do |i|
          d = Date.today + i
          @alert_forecasts[d] = @weather_station.alert(d)
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def weather_station_params
      params.require(:weather_station).permit(:latitude, :longitude, :name, :user_id)
    end
end
