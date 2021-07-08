class CleanWorker
  include Sidekiq::Worker

  def perform(*args)
    loop do
      Proxy::CleanService.new(logger).run
      sleep 10
    end
  end
end
