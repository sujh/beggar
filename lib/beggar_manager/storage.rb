require "redis-namespace"

class BeggarManager
  class Storage
    def initialize
      @pool = ConnectionPool.new(size: 5, timeout: 3) { Redis::Namespace.new(:beggar, redis: Redis.new(url: Rails.application.config_for(:redis).url)) }
    end

    def store(name, proxy)
      @pool.with do |conn|
        conn.multi do
          conn.sadd("proxies:#{name}", proxy)
          conn.inc("alive_proxy_count:#{name}")
        end
      end
    end

    def update_proxy_count(name, num)
      @pool.with do |conn|
        conn.incrby("proxy_count:#{name}", num)
      end
    end
  end
end
