require 'http'
require 'json'
require 'celluloid'
require 'reel'
require 'pry'

class FetchTimer
  include Celluloid

  def initialize
    @url = "http://api.timezonedb.com"
  end

  def get_time(time_zone)
    response = HTTP.get(@url, :params => { :zone => time_zone, :key => "TYI8FA9XP77L", :format => "json" }).to_s
    hash = JSON[response]

    Time.at(hash['timestamp']).utc
  end

end

zones = ['America/Los_Angeles', 'Asia/Colombo', 'Australia/Sydney', 'Africa/Johannesburg', 'Europe/Athens']


f = FetchTimer.new

Reel::Server::HTTP.run('127.0.0.1', 2609) do |connection|
  connection.each_request do |request|
    results = []
    zones.each do |element|
      result = f.future.get_time(element)
      results << result
    end

    my_hash = {zones[0] => results[0].value, zones[1] => results[1].value, zones[2] => results[2].value, zones[3] => results[3].value, zones[4] => results[4].value }
    string = JSON.generate(my_hash)
    request.respond :ok , string
  end
end
