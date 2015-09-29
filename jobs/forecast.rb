require 'date'
require 'net/https'
require 'json'

forecast_api_key       = Secrets.forecast["api_key"]
forecast_location_lat  = Secrets.forecast["lat"]
forecast_location_long = Secrets.forecast["long"]
forecast_units         = Secrets.forecast["us"]

def time_to_str(time_obj)
  Time.at(time_obj).strftime "%-l %P"
end

def time_to_str_minutes(time_obj)
  Time.at(time_obj).strftime "%-l:%M %P"
end

def day_to_str(time_obj)
  Time.at(time_obj).strftime "%a"
end

def time_to_hour(time_obj)
  Time.at(time_obj).strftime("%l %p")
end

SCHEDULER.every '5m', :first_in => 0 do |job|
  http = Net::HTTP.new("api.forecast.io", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  response = http.request(Net::HTTP::Get.new("/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"))
  forecast = JSON.parse(response.body)

  currently = forecast["currently"]
  current = {
    temperature: currently["temperature"].round,
    summary: currently["summary"],
    humidity: "#{(currently["humidity"] * 100).round}&#37;",
    wind_speed: currently["windSpeed"].round,
    wind_bearing: currently["windSpeed"].round == 0 ? 0 : currently["windBearing"],
    icon: currently["icon"]
  }

  daily = forecast["daily"]["data"][0]

  today = {
    summary: forecast["hourly"]["summary"],
    high: daily["temperatureMax"].round,
    low: daily["temperatureMin"].round,
    sunrise: time_to_str_minutes(daily["sunriseTime"]),
    sunset: time_to_str_minutes(daily["sunsetTime"]),
    icon: daily["icon"]
  }

  this_week, hourly = [], []
  for hour in (1..8)
    hour = forecast["hourly"]["data"][hour]
    this_hour = {
      temp: hour["temperature"].round,
      time: time_to_hour(hour["time"]),
      icon: hour["icon"],
      summary: hour["summary"],
      precipitation: hour["precipProbability"]
    }
    hourly.push(this_hour)
  end

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
  send_event('forecast', { current: current, hourly: hourly , upcoming_week: this_week } )
end

