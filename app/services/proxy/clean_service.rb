module Proxy
  class CleanService < Proxy::BaseService
    def initialize(logger = Rails.logger)
      super(logger)
      @storage = Storage.instance
    end

    def run
      dead_proxies = @storage.alive_proxies.select do |proxy|
        !proxy_is_alive?(proxy)
      end
      @storage.drop_from_alive_proxies(dead_proxies) if dead_proxies.present?
    end
  end
end
