# workers/message_poller_worker.rb
require_relative '../services/message_processor_service'

class MessagePollerWorker
  #include Logger

  def initialize
    log_info("📡 Запуск MessagePollerWorker...")
  end

  def run
    MessageProcessorService.new.run!
  end
end
