require_relative 'scans'
info = TorchInfo.new({
  "guid" => "test",
  "host" => "192.168.1.1"
  })
db = TorchDB.new('localhost')
puts db.current_utilization
