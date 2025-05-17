# services/message_processor_service.rb
require_relative '../models/message_item'
require_relative '../models/message'
require_relative '../models/message_item_source'
include AppLogger

class MessageProcessorService
  INTERVAL = 10 # секунд

  def run!
    loop do
      begin
        process_pending_messages
      rescue => e
        log_error(e, context: "Ошибка при обработке сообщений")
      end

      sleep INTERVAL
    end
  end

  private

  def process_pending_messages
    log_info("🔍 Поиск необработанных сообщений...")

    pending_messages = Message.pending

    return log_info("❌ Сообщений нет.") if pending_messages.empty?

    grouped_messages = pending_messages.group_by(&:grouped_id)

    grouped_messages.each do |grouped_id, group|
      if grouped_id.nil?
        handle_individual_message(group.first)
      else
        handle_grouped_messages(grouped_id, group)
      end
    end
  end

  def handle_individual_message(message)
    log_info("📬 Одиночное сообщение ID=#{message.message_id}, создаём запись в message_items...")

    source = find_or_create_message_source(message)

    item = MessageItem.create!(
      message_source_id: source.id,
      processed_text: message.text,
      status: "ready_to_work",
      created_at: message.date,
      updated_at: Time.now
    )

    MessageItemSource.create!(
      message_item_id: item.id,
      message_id: message.message_id,
      group_id: message.group_id
    )

    message.update_columns(sent_status: true, sent_at: Time.now)
    log_info("✅ Одиночное сообщение #{message.message_id} перенесено в message_items")
  end

  def handle_grouped_messages(grouped_id, parts)
    first_part = parts.min_by(&:date)

    # Если последнее сообщение старше 10 секунд — считаем, что группа завершена
    if Time.now - first_part.date > 10
      log_info("🔄 Группа #{grouped_id} завершена, создаём запись в message_items...")

      source = find_or_create_message_source(first_part)

      text = extract_text_from_group(parts)

      item = MessageItem.create!(
        grouped_id: grouped_id,
        message_source_id: source.id,
        processed_text: text,
        status: "ready_to_work",
        created_at: first_part.date,
        updated_at: Time.now
      )

      parts.each do |msg|
        MessageItemSource.create!(
          message_item_id: item.id,
          message_id: msg.message_id,
          group_id: msg.group_id
        )
        msg.update_columns(sent_status: true, sent_at: Time.now)
      end

      log_info("✅ Группа #{grouped_id} успешно перенесена в message_items")

    else
      log_info("⏳ Группа #{grouped_id} ещё не завершена, ждём...")
    end
  end

  def extract_text_from_group(parts)
    # Берём текст из первого сообщения, где он есть
    part_with_text = parts.find { |p| p.text.present? }
    part_with_text&.text || ""
  end

  def find_or_create_message_source(message)
    MessageSource.find_or_create_by!(
      source_type: "tggroup",
      external_id: message.group_id.to_s
    ) do |source|
      source.name = "Telegram Group ##{message.group_id}"
      source.link = "https://t.me/c/ #{message.group_id}/#{message.message_id}"
    end
  end
end
