require 'sinatra'
require_relative 'new_stephen/version'
require_relative 'sd_client'

USERNAME = ENV["USERNAME"]
PASSWORD = ENV["PASSWORD"]

set :root, File.expand_path(Dir.pwd)

get '/' do
  client = SDClient.new(USERNAME, PASSWORD)
  client.authenticate
  new_colbert = client.next_episode("33424","EP01906276")['new']
  program_id = client.next_episode("33424","EP01906276")['programID']
  original_airdate_post = client.post("programs", [program_id])
  original_airdate = JSON.parse(original_airdate_post.body)[0]['originalAirDate']

  erb :index, :locals => {
        :new_colbert => new_colbert,
        :original_airdate => original_airdate
      }
end
