class BegWorker
  include Sidekiq::Worker

  def perform(*args)
    old_proxies = Hash.new(Set.new)
    loop do
      Beggar.where(status: :ok).each do |beggar|
        old_proxies[beggar.name] = BegService.new(beggar).run(old_proxies[beggar.name])
      end
      sleep 10
    end
  end
end
