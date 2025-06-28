class Mutator
  PHONE_TEXT = "\n\n🚀 В наличии и под заказ, оптом и в розницу, отправим любой тк по предоплате или через гаранта Авито. Склады в Москве, Красноярске и Забайкальске.  Телефон для связи 8-913-590-4-777 Фёдор."

  PROMO_PATTERNS = [
    "Пиши в директ — сделаем выгодное предложение! ⚡️\nВ наличии на Малиновского 25/2\nКутузова 1стр105",
    "Отправка догрузом по всем городам от Забайкальска до Омска БЕСПЛАТНО!",
    "Отправка до Читы машина БЕСПЛАТНО!",
    "Комиссия агента 10 % от стоимости товара.",
    "Бесплатная доставка по РФ!",
    "📲Для заказа свяжитесь с менеджером: +79854485447",
    "В наличии в Красноярске",
    "В наличии на Малиновского 25/2",
    "Малиновского 25/2",
    "Кутузова 1стр105",
    "ул. Кутузова, 1 стр. 105.",
    "89955775669",
    "Пиши в директ — сделаем выгодное предложение!",
    "💬 Пиши в директ — сделаем выгодное предложение!",
    "💬 **Пиши в директ — сделаем выгодное предложение!**",
    "**Пиши в директ — сделаем выгодное предложение!**",
    "💬 Пиши в директ — сделаем выгодное предложение!",
    "В наличии на Малиновского 25/2",
    "⚡",
    "Наш адрес Новопоселковая 11с5",
    "****+79955775669****",
    "****+79697776163**",
    "📍Москва, ул. Новопоселковая 11с5",
    "+7 (985) 773-53-23",
    "+7 (915) 266-08-68",
    "⏰График работы:",
    "Пн-Пт: 10:00–18:00",
    "Сб-Вс: 10:00–15:00",
    "📩Пишите",
    "В наличии:",
    "Левый берег",
    "Правый берег",
    "ул. Малиновского, 25",
    "Кутузова, 1, стр. 105",
    "+7-995-577-56-69",
    "+7-969-777-61-63",
    "+79955775669",
    "+79697776163",
    "ул. Новопоселковая 11с5",
    "😊г. Москва, ул. Новопоселковая 11с5",
    "😊+7 (985) 773-53-23",
    "😊+7 (915) 266-08-68",
    "⏰** График работы:**  ",
    "📲Для заказа свяжитесь с менеджером: +79854485447",
    "Адрес: г. Москва,",
    "Для заказа обращайтесь по номерам:",
    "ПРАЙС С АКТУАЛЬНЫМИ ЦЕНАМИ",
    "Свяжитесь с нами для получения оптового прайс-листа и условий сотрудничества:",
    "💬 **Чат Ватсапп**",
    "💬 **Чат Телеграмм**",
    "📧 opt@china-line.org",
    "🤍🤍🤍",
    "Левый берег",
    "Правый берег",
    "⦁ ул. Кутузова, 1 стр. 105",
    "Наши адреса в Красноярске",
    "😊г. Москва,",
    "Наши адреса",
    "Ожидайте уже 10.04.24 в магазине-складе China-line по адресу .",
    "Для предзаказа обращайтесь по номерам:",
    "+7 985 448 54 47",
    "+7 985 773 53 23",
    "****📧**** ****opt@china-line.org**",
    "**Почта:** msk@china-line.org",
    "Или пишите на почту:",
    "msk@china-line.org",
    "Телефоны для заказа и вопросам сотрудничества:",
    "+79852129797",
    "+79581977565",
    "+79675558766",
    "По , Новопоселская 11с",
    "+7 (909) 150-88-78",
    "По заказам и любым интересующим Вас вопросам, обращайтесь по номерам",
    "➡️ **Где нас найти:**",
    "пгт. Забайкальск, ул. Северная 52Б",
    "📞 **Свяжитесь с нами:**",
    "⦁ +7 (914) 451-79-51",
    "⦁ +7 (928) 881-77-76",
    "+7-914-451-79-51",
    "+7-963-256-39-15",
    "Наши магазины находятся:",
    "Наши магазины**:",
    "тел. 8-963-256-39-15",
    "тел. 8-995-577-56-69",
    "тел. ****8-969-777-61-63****",
    "тел. ****8-995-577-56-69****",
    "• Ул. Кутузова, 1с105",
    "8-995-577-56-69",
    "ул. Северная 52Б",
    "+7 (914) 451-79-51",
    "Новопоселская 11с5",
    "п`о адресу: ",
    "📍** Адреса в Красноярске:**",
    "• Ул. Кутузова, 1с105",
    "г. Красноярск :",
    "Ул.Кутузова, 1с105",
    "+7 (914) 451-79-51**",
    "+7 (914) 451-79-51",
    "Ул. Кутузова, 1 ст. 105",
    "**opt@china-line.org",
    "opt@china-line.org",
    "Обращайтесь по телефонам:",
    "⤵️Обращайтесь по телефонам:",
    "Номера телефонов менеджеров:",
    ", Новопосёлковая 11с5.",
    "**Контакты:**",
    "на почту или в комментарии:",
    "+79940259324",
    "+79940259321",
    "+79940259326",
    "+79940259315**",
    "+79940259315",
    "+7 994 025-93-24",
    "ПГТ. ЗАБАЙКАЛЬСК ** ",
    "+7 994 025-93-21 ",
    "+7 994 025-93-26",
    "+7 994 025-93-15",
    "📞 +",
    "📞 \\+\\d",
    "Тел: \\+",
    "📞 \\*\\*\\+\\*\\*",
    "Заказ пишите на вацап  +79245030501",
    "Заказ пишите на вацап",
    "+79245030501",
    "89245030501
  ].sort_by { |pattern| -pattern.length }.freeze


  JUNK_LINES = [
    "**",
    " ",
    "  ",
    "   ",
    "    ",
    "+",
    "++",
    "+++",
    "++++",
    "*****",
    "****+****",
    "****+**",
    "⏰** :**",
    "💬 ! ⚡",
    "💬 **!** ⚡",
    "⚡",
    "🤍🤍🤍",
    "📍",
    "📩",
    "📩Пишите",
    "Или пишите на почту:",
    "Телефоны для заказа и вопросам сотрудничества:",
    "Почта:",
    "**Почта:** msk@china-line.org",
    "msk@china-line.org",
    "opt@china-line.org",
    "****📧**** ******",
    "/2",
    "▪️",
    "▪️**",
    "📎`",
    "•  ()",
    "⦁ **/2**",
    "⦁ Тел.: +",
    "⦁ ****",
    "⦁ Тел.: +",
    "**:**",
    ":",
    "📍 /2 (📞 ****+****)",
    "📍  (📞 ****+****)",
    "🔥!",
    "-  - ",
    "()",
    "📍** :**  ",
    "⦁ /2",
    "⦁\"",
    "**",
    "📲",
    "📧",
    "Контакты:",
    "`",
    "📞+ ",
    "на почту или в комментарии:",
    "💌",
    "Адрес:",
    "🏠",
    "📌",
    ", ",
    "➡️ **:**",
    "⦁ Email: ",
    "Наши :",
    "-  ",
    "Тел: +",
    "➡️ Наш адрес:",
    "******",
    " .",
    "Наши",
    "😊",
    "😊+",
    "😊+', ",
    "**Контакты:**",
    "**Ждём вас :**",
    "📧 **",
    "📞 :",
    "[",
    "⦁ +",
    "📞 **:**",
    "**:",
    "+**",
    " !  ",
    " ! ",
    " !",
    "/2 ()",
    "• /2 ()  ",
    "Москва: ",
    "Москва:",
    "Пгт.Забайкальск:",
    "Красноярск:",
    "Также :",
    "📍 Где купить?",
    "🌉 КРАСНОЯРСК — /2",
    "🏡 ",
    "🌉 КРАСНОЯРСК",
    "🏙 ",
    "📞 +",
    "📞",
    "📞 **+**",
    "📞 **:**",
    "⏰ Время работы:",
    "➡️ **:**",
    "**:"
  ].freeze

  COMMISSION_PATTERNS = [
    "Ваша комиссия"
  ].map(&:downcase).freeze

  SIMILARITY_THRESHOLD = 0.75

  def initialize(message_item)
    @message = message_item
  end

  def run
    puts "[MUTATOR] Обработка сообщения ID #{@message.id}..."

    begin
      #unless add_phone_number
      #  puts "[MUTATOR] ❌ Ошибка при добавлении телефона"
      #  return false
      #end

      unless remove_promo_text
        puts "[MUTATOR] ❌ Ошибка при удалении рекламного текста"
        return false
      end

      puts "[MUTATOR] ✅ Сообщение успешно изменено"
      true
    rescue => e
      puts "[MUTATOR] ❌ Ошибка: #{e.message}"
      false
    end
  end

  private

  def add_phone_number
    #sleep 1
    @message.reload

    current_text = @message.processed_text.to_s
    phone_regex = Regexp.escape(PHONE_TEXT.strip)

    return true if current_text.match?(/#{phone_regex}/i)

    updated_text = current_text + "\n\n" + PHONE_TEXT.strip
    @message.update!(processed_text: updated_text)
    true
  end

  def remove_promo_text
    #sleep 1
    @message.reload

    cleaned = exact_remove(@message.processed_text)
    cleaned = fuzzy_remove(cleaned)
    cleaned = remove_link_lines(cleaned) # <-- Новый шаг: удаление строк со ссылками
    cleaned = remove_commission_lines(cleaned) # <-- Новый шаг: удаление строк с комиссией
    cleaned = remove_junk_lines(cleaned) # <-- Новый шаг: удаление мусорных строк
    cleaned = cleaned.gsub(/(\n\s*){2,}/, "\n\n")
    cleaned = cleaned.gsub(/^\s*?\n/m, "\n")
    cleaned = cleaned.gsub(/\A\n+|\n+\z/, '')

    @message.update!(processed_text: cleaned.strip)
    true
  end

  def exact_remove(text)
    # Сначала самые длинные паттерны (уже отсортированы)
    PROMO_PATTERNS.reduce(text) do |current_text, pattern|
      # Убираем все спецсимволы из паттерна, оставляем только слова
      normalized_pattern = pattern.gsub(/[^\wа-яё]/iu, ' ').gsub(/\s+/, ' ').strip

      next current_text if normalized_pattern.empty?

      # Создаем regex, который ищет эту фразу с любыми пробелами/символами между словами
      words = normalized_pattern.split.map { |word| Regexp.escape(word) }
      regex = Regexp.new("#{words.join(".*")}", Regexp::IGNORECASE)

      if current_text.match?(regex)
        puts "[MUTATOR] 🧹 Точно удалено: '#{pattern}'"
        current_text.gsub(regex, '')
      else
        current_text
      end
    end
  end

  def fuzzy_remove(text)
    PROMO_PATTERNS.reduce(text) do |current_text, pattern|
      if similar?(current_text, pattern, threshold: SIMILARITY_THRESHOLD)
        current_text.gsub(/#{Regexp.escape(pattern)}/i, "")
      else
        current_text
      end
    end.strip
  end

  def similar?(text, pattern, threshold:)
    text_words = text.downcase.gsub(/[^\w\s]/, "").split
    pattern_words = pattern.downcase.gsub(/[^\w\s]/, "").split

    common_words = (text_words & pattern_words).size.to_f / pattern_words.size.to_f
    common_words >= threshold
  end

  # 🆗 Новый метод: удаляет целые строки, содержащие ссылки
  def remove_link_lines(text)
    lines = text.split("\n")
    filtered = lines.reject { |line| line =~ /(https?:\/\/|t\.me|wa\.me)/i }
    filtered.join("\n")
  end

  def remove_junk_lines(text)
    puts "[MUTATOR] 🧹 Чистка мусорных строк..."

    lines = text.split("\n")
    before_count = lines.size

    filtered = lines.reject do |line|
      line_normalized = line.strip

      # 1. Точное совпадение с предопределенным списком мусора
      next true if JUNK_LINES.include?(line_normalized)

      # 2. Строки, содержащие только спецсимволы/эмодзи без букв
      if line_normalized.match?(/\A[\p{Emoji}\p{P}\s\+]+\z/) && !line_normalized.match?(/[а-яa-z]/i)
        puts "[MUTATOR] 🗑️ Удалена строка (только символы): '#{line_normalized}'"
        next true
      end

      # 3. Строки-разделители (только пунктуация или цифры с символами)
      if line_normalized.match?(/\A[\p{P}\d\s\/–]+\z/)
        puts "[MUTATOR] 🗑️ Удалена строка (разделитель): '#{line_normalized}'"
        next true
      end

      # 4. Неполные строки контактов (эмодзи + пунктуация)
      if line_normalized.match?(/\A\p{Emoji}[\s\p{P}]+\z/)
        puts "[MUTATOR] 🗑️ Удалена строка (неполный контакт): '#{line_normalized}'"
        next true
      end

      false
    end

    after_count = filtered.size

    if before_count > after_count
      removed_count = before_count - after_count
      puts "[MUTATOR] ✨ Удалено #{removed_count} мусорных строк"
    else
      puts "[MUTATOR] 🧼 Мусорных строк не найдено"
    end

    filtered.join("\n")
  end

  def remove_commission_lines(text)
    puts "[MUTATOR] 🧹 Удаление строк с комиссией..."

    lines = text.split("\n")
    before_count = lines.size

    filtered = lines.reject do |line|
      line_normalized = line.downcase.strip
      COMMISSION_PATTERNS.any? { |pattern| line_normalized.include?(pattern) }
    end

    after_count = filtered.size

    if before_count > after_count
      removed_lines = lines - filtered
      puts "[MUTATOR] ✨ Удалены строки с комиссией:"
      removed_lines.each { |l| puts "[MUTATOR] ❌ '#{l}'" }
    else
      puts "[MUTATOR] 🧼 Строки с комиссией не найдены"
    end

    filtered.join("\n")
  end

end
