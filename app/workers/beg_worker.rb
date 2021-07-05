class BegWorker
  include Sidekiq::Worker

  def perform(*args)
    BeggarManager.new.run_forever
  end
end
