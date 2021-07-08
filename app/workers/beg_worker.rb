class BegWorker
  include Sidekiq::Worker

  def perform(*args)
    old_proxies = Hash.new(Set.new)
    loop do
      Beggar.where(status: :ok).each do |beggar|
        old_proxies[beggar.name] = Proxy::BegService.new(beggar, logger).run(old_proxies[beggar.name])
      end
      sleep 10
    end
  end
end
