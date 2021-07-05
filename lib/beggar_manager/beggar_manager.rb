require "open-uri"
require_relative "./storage"

class BeggarManager
  def initialize
    @storage = Storage.new
    @logger = Rails.logger
  end

  # Todo: Try use await insteat of thread
  def run_forever
    old_proxies = Hash.new([])
    loop do
      Beggar.where(status: :ok).each do |beggar|
        proxies = beg(beggar)
        diff_proxies = proxies - old_proxies[beggar.name]
        diff_proxies.each_with_object([]) do |proxy, threads|
          threads << Thread.new do
            @storage.store(beggar.name, proxy) if proxy_is_alive?(proxy)
          end
        end.each(&:join)
        @storage.update_proxy_count(beggar.name, diff_proxies.size)
        old_proxies[beggar.name] = proxies
      end
      sleep 30
    end
  end

  def beg(beggar)
    parser = JSON.parse(beggar.parser)
    doc = Nokogiri::HTML(URI.parse(beggar.site).open)
    ips = doc.css(parser["ip"])
    ports = doc.css(parser["port"])
    ips.map.with_index do |ip, idx|
      ip, port = ip.text.strip, ports[idx].text.strip
      ip = "http://#{ip}" unless ip.start_with?("http")
      "#{ip}:#{port}"
    end
  end

  private

  def proxy_is_alive?(proxy)
    Timeout.timeout(2) { !!URI.parse("http://www.baidu.com").open(proxy: proxy) and @logger.debug("#{proxy} ok") }
  rescue Timeout::Error, Errno::ECONNREFUSED
    @logger.debug("#{proxy} is dead")
    false
  end
end
