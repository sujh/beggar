class Proxy::Storage
  private_class_method :new

  def self.instance
    @instance ||= new
  end

  def initialize
    @pool = ConnectionPool.new(size: 5, timeout: 3) { Redis::Namespace.new(:proxy, redis: Redis.new(url: Rails.application.config_for(:redis).url)) }
  end

  def store(name, proxy)
    @pool.with do |conn|
      conn.multi do
        conn.sadd("alive", proxy)
        conn.incr("history_alive_count:#{name}")
      end
    end
  end

  def update_proxy_count(name, num)
    @pool.with do |conn|
      conn.incrby("total_count:#{name}", num)
    end
  end

  def drop_from_alive_proxies(proxies)
    @pool.with do |conn|
      conn.srem("alive", Array(proxies))
    end
  end

  def alive_proxies
    @pool.with do |conn|
      conn.smembers("alive_proxies")
    end
  end
end
