require 'sinatra'
require_relative 'new_stephen/version'
require_relative 'sd_client'

USERNAME = ENV["USERNAME"]
PASSWORD = ENV["PASSWORD"]

set :root, File.expand_path(Dir.pwd)

get '/' do
  client = SDClient.new(USERNAME, PASSWORD)
  client.authenticate
  next_colbert = client.next_episode("33424","EP01906276")['new']

  erb :index, :locals => {:next_colbert => next_colbert }
end
