require 'logger'
require_relative 'main'

#\ -p 4567 -o 0.0.0.0
log = File.new("sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

configure do
  LOGGER = Logger.new("sinatra.log")
  enable :logging, :dump_errors
  set :raise_errors, true
end

run TorchApp.new
