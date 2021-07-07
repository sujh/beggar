require "open-uri"

class BegService
  attr_reader :beggar

  def initialize(beggar)
    @beggar = beggar
    @logger = Rails.logger
    @storage = Storage.new
  end

  def run(old_proxies = Set.new)
    proxies = beg(5, old_proxies)
    diff_proxies = proxies - old_proxies
    diff_proxies.each_with_object([]) do |proxy, threads|
      threads << Thread.new do
        @storage.store(beggar.name, proxy) if proxy_is_alive?(proxy)
      end
    end.each(&:join)
    @storage.update_proxy_count(beggar.name, diff_proxies.size)
    proxies < old_proxies ? old_proxies : proxies
  end

  def beg(max_page = 1, old_proxies = Set.new)
    parser = JSON.parse(beggar.parser)
    (1..max_page).each_with_object(Set.new) do |page, rst|
      @logger.debug { "Begging to #{beggar.paged_site(page)}" }
      doc = Nokogiri::HTML(http_get(beggar.paged_site(page)))
      ips = doc.css(parser["ip"])
      ports = doc.css(parser["port"])
      ips.each_with_index do |ip, idx|
        ip, port = ip.text.strip, ports[idx].text.strip
        ip = "http://#{ip}" unless ip.start_with?("http")
        rst << "#{ip}:#{port}"
        if rst < old_proxies
          return rst
        end
      end
      sleep 2
    end
  end

  def http_get(uri, options = {})
    ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    URI.parse(uri).open(options.merge({"User-Agent" => ua}))
  end

  private

  def proxy_is_alive?(proxy)
    test_host = "https://www.baidu.com"
    !!http_get(test_host, open_timeout: 2, read_timeout: 1, proxy: proxy) and @logger.debug("#{proxy} ok")
  rescue => e
    @logger.debug { "#{proxy} is dead, caused by: #{e}" }
    false
  end
end

class BegService::Storage
  def initialize
    @pool = ConnectionPool.new(size: 5, timeout: 3) { Redis::Namespace.new(:beggar, redis: Redis.new(url: Rails.application.config_for(:redis).url)) }
  end

  def store(name, proxy)
    @pool.with do |conn|
      conn.multi do
        conn.sadd("proxies:#{name}", proxy)
        conn.incr("alive_proxy_count:#{name}")
      end
    end
  end

  def update_proxy_count(name, num)
    @pool.with do |conn|
      conn.incrby("proxy_count:#{name}", num)
    end
  end
end
