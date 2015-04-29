# Entry point for Torch

require 'sinatra'
require_relative 'scans'

class TorchApp < Sinatra::Base
  def initialize
    @db = TorchDB.new("localhost")
    super(self)
  end
  configure do
    set :static, true
    set :public_folder, File.dirname(__FILE__) + '/static'
  end
  get '/' do
    'Basic Hello'
  end
  get '/scans' do
    scans = @db.list_active_scans()
    erb :list, :locals => {:scans => scans}
  end
  post '/update' do
    request.body.rewind  # in case someone already read it
    data = TorchInfo.new(JSON.parse request.body.read)
    @db.update(data)
    halt 200
  end
end
