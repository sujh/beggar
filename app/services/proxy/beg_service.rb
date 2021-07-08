module Proxy
  class BegService < Proxy::BaseService
    attr_reader :beggar

    def initialize(beggar, logger = Rails.logger)
      super(logger)
      @beggar = beggar
      @storage = Storage.instance
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
        @logger.info { "Begging to #{beggar.paged_site(page)}" }
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
        sleep 2 if max_page > 1
      end
    end
  end
end
