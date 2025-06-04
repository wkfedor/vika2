# services/message_processor_worker.rb

# Подключаем зависимости
require_relative 'censor'
require_relative 'mutator'
require_relative 'quality_control'

# Подключаем логгер
include AppLogger

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
    log_info("🔍 Начинаем поиск сообщений для обработки...")

    # Получаем список ID, которые нужно обработать
    ids_to_process = fetch_message_ids

    # Если нет подходящих ID — выходим
    if ids_to_process.empty?
      return log_info("❌ Нет подходящих сообщений")
    end

    log_info("📬 Начинаем обработку #{ids_to_process.count} сообщений")

    # Обрабатываем каждое сообщение
    ids_to_process.each do |id|
      #Thread.new do
        message = MessageItem.find_by(id: id)

        unless message
          log_info("[SKIPPED] Сообщение с ID=#{id} не найдено")
          return
        end

        process_message(message)
        # end
    end
  end

  def fetch_message_ids
    if @custom_message_ids && !@custom_message_ids.empty?
      # Берём только те ID, у которых статус 'new'
      MessageItem.where(id: @custom_message_ids).where(status: 'new').pluck(:id)
    else
      # Все сообщения со статусом 'new'
      MessageItem.where(status: 'new').pluck(:id)
    end
  end

  def process_message(message)
    log_info("[PROCESSING] Сообщение ID=#{message.id}, текст: '#{message&.processed_text || ''}'")

      begin
        message.reload.start_processing!
        message.save!
        log_info("[STATUS] ID=#{message.id} → processing")
        #sleep 2

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

        #sleep 2

        # 📌 НАЧИНАЕМ МУТАЦИЮ
        message.reload.start_mutation!
        message.save!
        log_info("[STATUS] ID=#{message.id} → in_mutation")
        #sleep 2

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

