# Entry point for Torch

require 'sinatra'
require_relative 'scans'

class TorchApp < Sinatra::Base
  def initialize
    @db = TorchDB.new("localhost")
    super()
  end
#  configure do
#    set :static, true
#    set :public_folder, File.dirname(__FILE__) + '/static'
#  end
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
  get '/idle' do
    data = @db.list_idle_nodes()
    erb :idle, :locals => {:nodes => data }
  end
  get '/rdc/:node' do
    headers "Content-Disposition" => "attachment; filename=#{params['node']}.rdp"
    erb :rdc, :layout => false, :content_type => 'application/octet-stream', :locals => {:node => params['node']}
  end
end
