# services/message_processor_service.rb
require_relative '../models/message_item'
require_relative '../models/message'
require_relative '../models/message_item_source'
include AppLogger

class MessageProcessorService
  INTERVAL = 1 # секунд

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
      status: "new",
      created_at: message.date,
      updated_at: Time.now,
      send_group_id: 5
    )

    MessageItemSource.create!(
      message_item_id: item.id,
      message_id: message.id,
      group_id: message.group_id
    )

    message.update_columns(sent_status: true, sent_at: Time.now)

    # После создания message_item собираем медиафайлы
    collect_media_files_for(item)

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
        status: "new",
        created_at: first_part.date,
        updated_at: Time.now,
        send_group_id: 5   #todo сделать привязку не по ид а по ключу, так же вынести значение по умолчанию
      )

      parts.each do |msg|
        MessageItemSource.create!(
          message_item_id: item.id,
          message_id: msg.id,
          group_id: msg.group_id
        )
        msg.update_columns(sent_status: true, sent_at: Time.now)
      end

      # После создания message_item собираем медиафайлы
      collect_media_files_for(item)

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

  # === Метод для сбора медиафайлов ===
  def collect_media_files_for(message_item)
    log_info("[MediaFiles] 📷 Запуск метода для MessageItem ID: #{message_item.id}")

    if message_item.media_files.present?
      log_info("[MediaFiles] ❌ media_files уже заполнен. Пропускаем.")
      return
    end

    sources = message_item.sources

    unless sources.any?
      log_info("[MediaFiles] ❌ Нет связанных sources. Пропускаем.")
      return
    end

    found_files = []
    checked_dirs = [] # Массив для отслеживания всех проверенных директорий

    sources.each do |source|
      # puts "1*"*100
      # puts source.inspect


      group_id = source.message&.group_id
      message_id = source.message&.message_id

      # puts "2*"*100
      # puts source.message.inspect
      # puts message_id.inspect

      next unless group_id && message_id

      media_dir = "/home/feda/py/read-messages-from-group/media/group_#{group_id}/msg_#{message_id}"

      # puts "3*"*100
      # puts media_dir

      checked_dirs << media_dir # Сохраняем путь для отчета
      log_info("[MediaFiles] 🔍 Проверяем директорию: #{media_dir}")

      if Dir.exist?(media_dir)
        files = Dir.glob("#{media_dir}/*").select { |f| File.file?(f) }

        if files.any?
          relative_paths = files.map { |f| f.sub("/home/feda/py/read-messages-from-group", "") }
          log_info("[MediaFiles] ✅ Найдено #{files.size} файла(ов):")
          relative_paths.each { |p| log_info(" - #{p}") }

          found_files.concat(relative_paths)
        else
          log_info("[MediaFiles] 📄 Файлы отсутствуют в директории:")
          log_info(" - #{media_dir}")
        end
      else
        log_info("[MediaFiles] 📁 Директория не найдена или недоступна:")
        log_info(" - #{media_dir}")
      end
    end

    if found_files.any?
      message_item.update!(media_files: found_files.uniq.to_json)
      log_info("[MediaFiles] ✅ media_files успешно обновлено")
    else
      message_item.update!(media_files: [].to_json)
      if checked_dirs.any?
        log_info("[MediaFiles] 🚫 Ни в одной из проверенных директорий не найдено медиафайлов:")
        checked_dirs.each { |dir| log_info(" - #{dir}") }
      else
        log_info("[MediaFiles] 🚫 Нет доступных директорий для проверки (отсутствуют group_id или message_id)")
      end
    end
  rescue => e
    log_error(e, context: "[MediaFiles] ⚠️ Ошибка при обработке медиафайлов для MessageItem ID=#{message_item.id}")
    message_item.update!(media_files: [])
  end


end
