require_relative 'scans'
db = TorchDB.new('localhost')
puts db.current_utilization
puts db.list_idle_nodes()
