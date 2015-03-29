require 'date'
require 'net/https'
require 'json'

def url
  config = YAML::load_file('config.yml')

  api_key = config['forecast_api_key']
  latitude = config['forecast_latitude']
  longitude = config['forecast_longitude']

  forecast_units = "ca" # like "si", except windSpeed is in kph
  "/forecast/#{api_key}/#{latitude},#{longitude}?units=#{forecast_units}"
end

def time_to_str(time_obj)
  Time.at(time_obj).strftime "%-l %P"
end

def time_to_str_minutes(time_obj)
  Time.at(time_obj).strftime "%-l:%M %P"
end

def day_to_str(time_obj)
  Time.at(time_obj).strftime "%a"
end

def request
  http = Net::HTTP.new("api.forecast.io", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  response = http.request(Net::HTTP::Get.new(url))
  JSON.parse(response.body)
end


def current(forecast)
  currently = forecast["currently"]
  {
    temperature: currently["temperature"].round,
    summary: currently["summary"],
    humidity: "#{(currently["humidity"] * 100).round}&#37;",
    wind_speed: currently["windSpeed"].round,
    wind_bearing: currently["windSpeed"].round == 0 ? 0 : currently["windBearing"],
    icon: currently["icon"]
  }
end

def today(forecast)
  daily = forecast["daily"]["data"][0]
  {
    summary: forecast["hourly"]["summary"],
    high: daily["temperatureMax"].round,
    low: daily["temperatureMin"].round,
    sunrise: time_to_str_minutes(daily["sunriseTime"]),
    sunset: time_to_str_minutes(daily["sunsetTime"]),
    icon: daily["icon"]
  }
end

def this_week(forecast)
  this_week = []
  for day in (1..7)
    day = forecast["daily"]["data"][day]
    this_day = {
      max_temp: day["temperatureMax"].round,
      min_temp: day["temperatureMin"].round,
      time: day_to_str(day["time"]),
      icon: day["icon"]
    }
    this_week.push(this_day)
  end
  this_week
end


SCHEDULER.every '5m', :first_in => 0 do |job|
  forecast = request
  current = current(forecast)
  today = today(forecast)
  this_week = this_week(forecast)

  send_event('forecast', {
    current: current,
    today: today,
    upcoming_week: this_week,
  })
end
