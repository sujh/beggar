require "open-uri"

class Proxy::BaseService
  def initialize(logger)
    @logger = logger
  end

  private

  def http_get(uri, options = {})
    ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    URI.parse(uri).open(options.merge({"User-Agent" => ua}))
  end

  def proxy_is_alive?(proxy)
    test_host = "https://www.baidu.com"
    !!http_get(test_host, open_timeout: 2, read_timeout: 1, proxy: proxy) and @logger.debug("#{proxy} ok")
  rescue => e
    @logger.debug { "#{proxy} is dead, caused by: #{e}" }
    false
  end
end
