# services/message_processor_worker.rb

class MessageProcessorWorker
  INTERVAL = 10 # секунд между проверками

  def initialize(message_ids: nil)
    @custom_message_ids = message_ids
  end

  def run
    loop do
      process_messages
      sleep INTERVAL
    end
  end

  private

  def process_messages
    if @custom_message_ids && !@custom_message_ids.empty?
      messages = MessageItem.where(id: @custom_message_ids).where(status: 'new')
    else
      messages = MessageItem.where(status: 'new')
    end

    return log_info("❌ Нет подходящих сообщений") if messages.empty?

    log_info("📬 Начинаем обработку #{messages.count} сообщений")

    messages.each do |msg|
      Thread.new do
        process_message(msg)
      end
    end
  end

  def process_message(message)
    log_info("[PROCESSING] Сообщение ID=#{message.id}, текст: '#{message.processed_text[0..30] || ''}'")

    begin
      message.reload.start_processing!
      message.save!
      log_info("[STATUS] ID=#{message.id} → processing")
      sleep 2

      censor = Censor.new(message)
      if censor.run
        message.reload.pass_censor!
        message.save!
        log_info("[STATUS] ID=#{message.id} → censored")
      else
        message.reload.fail_censor!
        message.save!
        log_info("[STATUS] ID=#{message.id} → censored_failed")
        return
      end

      sleep 2

      mutator = Mutator.new(message)
      if mutator.run
        message.reload.succeed_mutation!
        message.save!
        log_info("[STATUS] ID=#{message.id} → mutated")
      else
        message.reload.fail_mutation!
        message.save!
        log_info("[STATUS] ID=#{message.id} → mutation_failed")
        return
      end

      qc = QualityControl.new(message)
      qc.approve

    rescue => e
      log_error(e, context: "[ERROR] Ошибка при обработке сообщения ID=#{message.id}")
      message.reload.mark_as_error!
      message.save!
      log_info("[STATUS] ID=#{message.id} → error")
    end
  end
end
