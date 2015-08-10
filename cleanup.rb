require 'redis'
require 'json'
require_relative 'scans'

db = TorchDB.new('localhost')
r = Redis.new(:host => 'localhost')

# Find heartbeats over 120s old

while(true) do
# Now minus 120 seconds
t = Time.now.to_i - 120

r.zrangebyscore("heartbeat", t - 360, t.to_i).each do |scan|
  info = TorchInfo.new(JSON.parse(r.get("scan:#{scan}")))
  info.state = "STALE"
  r.set("scan:#{scan}", info.to_json)
end

r.zrangebyscore("heartbeat", 0, t.to_i - 360).each do |scan|
  info = TorchInfo.new(JSON.parse(r.get("scan:#{scan}")))
  info.state = "DEAD"
  r.multi do
    r.srem("scans:active", scan)
    r.zrem("heartbeat", scan)
    score = r.zincrby("nodes:count", -1, info.host)
    if (score == 0)
      r.srem("nodes:active", info.host)
    end
    r.set("scan:#{scan}", info.to_json)
  end
end

sleep(10)
end


