# services/censor.rb

class Censor
  # Белый список пользователей по группам
  WHITELIST = {
    1551946392 => ["opt_zabaikalsk"],
    1628399582 => ["opt75"],
    2225744678 => ["nil", "opt75", "CHINA_LINE_MSK", "pirokindyk","strknr"], # nil → разрешает отправителей с sender_username = nil
    978474978 => ["Yuliya_Dorogan", "ke_7277","Vladsbogom96"]
  }.transform_values { |users| users.map(&:to_s).map(&:downcase) }

  # Черный список слов: если встречается хотя бы одно — цензура
  BLACKLISTED_WORDS = [
    'дропшиппинг',
    'dropshipping',
    'партнёрская программа'
  ].freeze

  # Черный список расширений по группам
  BLACKLISTED_EXTENSIONS = {
    1551946392 => ["xlsx", "xls", "pdf", "docx", "pptx"],
    1628399582 => ["xlsx", "xls", "pdf"],
    2225744678 => ["xlsx", "xls", "pdf"],
    978474978 => ["xlsx", "xls", "pdf"]
  }.freeze

  def initialize(message_item)
    @message = message_item
  end

  def run
    puts "[CENSOR] 🔍 Начинаем проверку сообщения ID #{@message.id}..."

    text_preview = @message.processed_text ? @message.processed_text.truncate(100) : "Нет текста"
    puts "[CENSOR] 📝 Текст сообщения: #{text_preview}"

    unless check_sender_whitelist
      puts "[CENSOR] ❌ Отправитель не прошёл белый список"
      return false
    end

    if contains_blacklisted_words?
      puts "[CENSOR] ❌ Сообщение содержит запрещённые слова"
      return false
    end

    if has_blacklisted_attachments?
      puts "[CENSOR] ❌ Сообщение содержит запрещённые вложения"
      return false
    end

    puts "[CENSOR] ✅ Сообщение прошло все проверки"
    true
  end

  private

  # 🟢 Проверяет, находится ли отправитель в белом списке
  def check_sender_whitelist
    puts "[CENSOR] 🔒 Проверка белого списка..."

    related_message_ids = MessageItemSource.where(message_item_id: @message.id).pluck(:message_id)

    if related_message_ids.blank?
      puts "[CENSOR] ⚠️ Нет связанных сообщений"
      return false
    end

    puts "[CENSOR] 💬 Найдены message_id: #{related_message_ids.join(', ')}"

    related_messages = Message.where(id: related_message_ids).pluck(:group_id, :sender_username)

    if related_messages.empty?
      puts "[CENSOR] ⚠️ Нет данных о группах или отправителях"
      return false
    end

    puts "[CENSOR] 🔎 Проверяем каждое сообщение..."

    related_messages.each do |group_id, sender|
      if WHITELIST.key?(group_id)
        allowed_users = WHITELIST[group_id].map(&:to_s).map(&:downcase)

        # Если отправитель nil или пустой
        if sender.nil? || sender.to_s.strip == ""
          if allowed_users.include?("nil")
            puts "[CENSOR] ✅ Разрешённый отправитель: NIL (владелец канала)"
            return true
          else
            puts "[CENSOR] ⚠️ Отправитель не указан и не разрешён для группы #{group_id}"
            next
          end
        end

        sender_down = sender.downcase

        if allowed_users.include?(sender_down)
          puts "[CENSOR] ✅ Совпадение: '#{sender}' в белом списке для группы #{group_id}"
          return true
        else
          puts "[CENSOR] ⚠️ Отправитель '#{sender}' НЕ в белом списке для группы #{group_id}"
        end

      else
        puts "[CENSOR] 🟡 Группа #{group_id} — НЕ в белом списке. Цензура пропущена."
        return true
      end
    end

    puts "[CENSOR] ❌ Ни одно сообщение не прошло по белому списку"
    false
  end

  # 🔴 Проверяет, содержится ли в тексте запрещённое слово
  def contains_blacklisted_words?
    text = @message.processed_text.to_s.downcase

    BLACKLISTED_WORDS.each do |word|
      if text.include?(word.downcase)
        puts "[CENSOR] 🔥 Найдено запрещённое слово: '#{word}'"
        return true
      end
    end

    puts "[CENSOR] ✅ Запрещённых слов не найдено"
    false
  end

  # 📁 Проверяет, есть ли запрещённые вложения в сообщении
  def has_blacklisted_attachments?
    puts "[CENSOR] 📁 Проверка вложений..."

    raw_media_files = @message.read_attribute_before_type_cast(:media_files)

    if raw_media_files.blank?
      puts "[CENSOR] 📦 Вложений нет"
      return false
    end

    begin
      media_files = JSON.parse(raw_media_files)
    rescue JSON::ParserError
      puts "[CENSOR] ⚠️ Ошибка парсинга media_files"
      return false
    end

    # Получаем group_id сообщения
    related_group_ids = MessageItemSource
                          .where(message_item_id: @message.id)
                          .joins(:message)
                          .pluck("messages.group_id")
                          .uniq

    found_extension = nil

    media_files.each do |filepath|
      next unless filepath.is_a?(String)

      # Получаем имя файла
      filename = filepath.to_s.strip

      # Извлекаем расширение
      parts = filename.split('.')
      next if parts.size < 2
      extension = parts.last.downcase

      related_group_ids.each do |group_id|
        blacklisted = BLACKLISTED_EXTENSIONS[group_id]&.map(&:downcase)
        next unless blacklisted

        if blacklisted.include?(extension)
          found_extension = extension
          puts "[CENSOR] 🔥 Найдено запрещённое расширение '#{extension}' для группы #{group_id} в файле '#{filename}'"
          break
        end
      end

      return true if found_extension
    end

    puts "[CENSOR] ✅ Запрещённых вложений не найдено"
    false
  end
end
