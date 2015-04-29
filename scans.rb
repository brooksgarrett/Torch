require 'redis'
require 'json'

class TorchInfo < Object
  attr_accessor :user, :guid, :count, :state, :host, :site
  def initialize(o)
    @guid  = o["guid"]
    @user  = o["user"] || ""
    @site  = o["site"] || ""
    @count = o["count"] || 0
    @state = o["state"] || ""
    @host  = o["host"]  || ""
  end
  def to_json(*a)
    {
      "user" => @user, 
      "guid" => @guid,
      "count" => @count,
      "state" => @state, 
      "site" => @site,
      "host" => @host 
    }.to_json(*a)
  end
  def self.json_create(o)
    new(o)
  end
  def to_s
    return "u: #{@user}, g: #{@guid}, c: #{@count}, s: #{@state}, h: #{@host}, s: #{site}"
  end
end

class TorchDB
  def initialize(dbHost)
    @r = Redis.new(:host => dbHost)
  end
  def start(info)
    @r.sadd("nodes:active", info.host)
    @r.sadd("nodes:known", info.host)
    @r.sadd("scans:active", info.guid)
    @r.sadd("scans:known", info.guid)
    @r.zincrby("nodes:count", 1, info.host)
  end
  def stop(info)
    @r.srem("nodes:active", info.host)
    @r.srem("scans:active", info.guid)
    @r.zincrby("nodes:count", -1, info.host)
  end
  def update(info)
    rInfo = @r.get(info.to_json)
    @r.zadd("heartbeat", Time.now.to_i, info.guid)
    if (rInfo == nil)
      @r.set("scan:#{info.guid}", info.to_json)
      self.start(info)
    else
      @r.set("scan:#{info.guid}", info.to_json)
      if (info.state = "Stopped")
        self.stop(info)
      end
    end
  end
  def list_active_scans()
    scans = Array.new
    @r.smembers("scans:active").each { |s|
      scans.push TorchInfo.new(JSON.parse(@r.get("scan:#{s}")))
    }
    return scans
  end
  def current_utilization()
    util = @r.scard("scans:active").to_f / @r.scard("nodes:known").to_f
    return util * 100
  end
end
