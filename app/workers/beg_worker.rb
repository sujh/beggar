class BegWorker
  include Sidekiq::Worker
  sidekiq_options queue: "critical"

  def perform(beggar_id)
    logger.info("start begging with beggar_id #{beggar_id}")
    beggar = Beggar.find(beggar_id)
    Proxy::BegService.new(beggar, logger).run(Proxy::Storage.instance.old_proxies(beggar_id))
  end
end
