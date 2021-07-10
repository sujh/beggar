class CleanWorker
  include Sidekiq::Worker
  sidekiq_options queue: "critical"

  def perform(*args)
    logger.info("start cleaning...")
    loop do
      Proxy::CleanService.new(logger).run
      sleep 10
    end
  end
end
