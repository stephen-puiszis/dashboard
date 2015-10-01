require 'net/http'
require 'json'
require 'active_support'
require 'active_support/core_ext'
require 'action_view'
require_relative 'secrets'

# makes requests to the Chicago Transit Authority API to get estimated travel times
#  for the requested spots visit http://www.transitchicago.com/developers/traintracker.aspx
#  to learn about the API and to get a key
class ChicagoTransitData
  include ActionView::Helpers
  attr_accessor :response, :train_times, :bus_times, :train_stations, :bus_stations, :options

  API_KEY = Secrets.cta_api_key.freeze
  TRAIN_URL = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx".freeze
  BUS_URL = "http".freeze

  def initialize(stations, options = {})
    @train_stations = stations[:train]
    @bus_stations = stations[:bus]
    @options = options
  end

  def arrival_times
    { train: get_train_times }
  end

  def make_request(url, params)
    uri = URI(url).tap do |u|
      u.query = URI.encode_www_form(params)
    end

    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.get(uri)
    end
  end

  private

  def train_params
    { key: API_KEY, stpid: train_stations }.merge(options)
  end

  def bus_params
    { key: API_KEY, stpid: bus_stations }.merge(options)
  end

  def get_bus_times
    @response = make_request(BUS_URL, bus_params)
    @bus_times = Hash.from_xml(@response.body)["ctatt"]["eta"]
  end

  def get_train_times
    @response = make_request(TRAIN_URL, train_params)
    @train_times = transform_data(Hash.from_xml(@response.body)["ctatt"]["eta"])
  end

  def transform_data(data)
    # pre-sort our data as we will be using an ActionView::Helper for time
    data.sort {|a,b| a["arrT"] <=> b["arrT"] }
    transformed = data.each_with_object([]) do |hash, memo|
      memo << {
        station: hash["staNm"],
        route: train_line_map[hash["rt"]] || hash["rt"],
        direction: train_direction_map[hash["trDr"]] || hash["trDr"],
        arrival_time: distance_of_time_in_words_to_now(
          Time.parse(hash["arrT"]), include_seconds: true)
      }
    end
    transformed
  end

  def train_direction_map
    {
      "1" => "North",
      "5" => "South"
    }
  end

  def train_line_map
    {
      "Brn" => "Brown",
      "P"   => "Purple",
      "Blu" => "Blue",
      "Org" => "Orange"
    }
  end

end
