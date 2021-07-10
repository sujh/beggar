class Proxy::Storage
  private_class_method :new

  def self.instance
    @instance ||= new
  end

  def initialize
    @pool = ConnectionPool.new(size: 5, timeout: 3) { Redis::Namespace.new(:proxy, redis: Redis.new(url: Rails.application.config_for(:redis).url)) }
  end

  def store_proxy(key, proxy, old_proxies = nil)
    @pool.with do |conn|
      conn.multi do
        conn.sadd("alive", proxy)
        conn.incr("history_alive_count:#{key}")
      end
    end
  end

  def refresh_proxy_info(key, alive_proxies:, total_count:, old_proxies: [])
    @pool.with do |conn|
      conn.multi do
        if alive_proxies.present?
          conn.sadd("alive", Array(alive_proxies))
          conn.incrby("history_alive_count:#{key}", alive_proxies.size)
        end
        conn.incrby("history_total_count:#{key}", total_count)
        if old_proxies.present?
          conn.del("old:#{key}")
          conn.sadd("old:#{key}", Array(old_proxies))
        end
      end
    end
  end

  def old_proxies(key)
    @pool.with do |conn|
      conn.smembers("old:#{key}").to_set
    end
  end

  def drop_from_alive_proxies(proxies)
    @pool.with do |conn|
      conn.srem("alive", Array(proxies))
    end
  end

  def alive_proxies
    @pool.with do |conn|
      conn.smembers("alive")
    end
  end
end
