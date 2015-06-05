require 'http'
require 'json'
require 'celluloid'
require 'reel'
require 'pry'

class FetchTimer
  include Celluloid

  def initialize
    @url = "http://api.timezonedb.com/?zone="
  end

  def get_time(time_zone)
    @url << time_zone
    @url << "&key=TYI8FA9XP77L&format=json"
    response = HTTP.get(@url).to_s
    hash = JSON[response]

    Time.at(hash['timestamp']).utc
  end

end

zones = ['America/Los_Angeles', 'Asia/Colombo', 'Australia/Sydney', 'Africa/Johannesburg', 'Europe/Athens']
results = []



Reel::Server::HTTP.run('127.0.0.1', 2609) do |connection|
  connection.each_request do |request|

    zones.each do |element|
      f = FetchTimer.new
      result = f.future.get_time(element)
      results << result
    end

    my_hash = {:Los_Angeles => results[0].value, :Colombo => results[1].value, :Sydney => results[2].value, :Johannesburg => results[3].value, :Athens => results[4].value }
    string = JSON.generate(my_hash)

    request.respond :ok , string
  end
end


