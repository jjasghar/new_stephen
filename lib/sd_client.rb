require 'active_support/core_ext/date'
require 'net/http'
require 'digest/sha1'
require 'json'


class SDClient

  class ServiceOffline < StandardError
    def initialize(msg="Opps Upstream service offline, please try again in 30 minutes.")
      super(msg)
    end
  end

  attr_reader :username
  attr_reader :password
  attr_reader :token

  def initialize(username,password)
    @username = username
    @password = Digest::SHA1.hexdigest password
  end

  def authenticate
    auth_request_body = {"username":"#{username}", "password":"#{password}"}.to_json

    token_endpoint = URI.parse("https://json.schedulesdirect.org/20141201/token")

    auth_post = Net::HTTP::Post.new(token_endpoint.request_uri)
    auth_post.body = auth_request_body

    http = Net::HTTP.new(token_endpoint.host)

    response = http.request(auth_post)

    raise ServiceOffline if JSON.parse(response.body)['code'] == 3000

    @token = JSON.parse(response.body)['token']

  end

  def get(endpoint, *params)
    url = URI.parse("https://json.schedulesdirect.org/20141201/#{endpoint}?#{params.join('&')}")

    request = Net::HTTP::Get.new(url)
    request.add_field("token",token)

    response = Net::HTTP.new(url.host).start do |http|
      http.request(request)
    end
  end

  def put(endpoint, *params)
    url = URI.parse("https://json.schedulesdirect.org/20141201/#{endpoint}?#{params.join('&')}")

    request = Net::HTTP::Put.new(url)
    request.add_field("token",token)

    response = Net::HTTP.new(url.host).start do |http|
      http.request(request)
    end
  end

  def post(endpoint, body)
    url = URI.parse("https://json.schedulesdirect.org/20141201/#{endpoint}")

    request = Net::HTTP::Post.new(url)
    request.add_field("token",token)
    request.body = body.to_json

    response = Net::HTTP.new(url.host).start do |http|
      http.request(request)
    end
  end

  def next_episode(station, show_id)

    # get the schedules from today to the beginning of next week (monday midnight)
    dates = (Date.today..Date.today.next_week).map(&:to_s)
    local_station = [{"stationID": station, "date": dates}]

    sched_response = post("schedules", local_station)
    sched = JSON.parse(sched_response.body)

    # find the all the uniq ids for the programs in the schedules
    sched.map do |s|
      s["programs"].keep_if do |p|
        p['programID'] =~ /#{show_id}/ && (DateTime.parse(p['airDateTime']) > DateTime.now)
      end
    end.flatten.sort_by{|p| DateTime.parse(p['airDateTime'])}.first
  end



end
