class Mutator
  PHONE_TEXT = "\n\nЗвоните 89509901103"

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
    "****📧**** ****opt@china-line.org**"

  ].sort_by { |pattern| -pattern.length }.freeze

  SIMILARITY_THRESHOLD = 0.75

  def initialize(message_item)
    @message = message_item
  end

  def run
    puts "[MUTATOR] Обработка сообщения ID #{@message.id}..."

    begin
      unless add_phone_number
        puts "[MUTATOR] ❌ Ошибка при добавлении телефона"
        return false
      end

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
    sleep 1
    @message.reload

    current_text = @message.processed_text.to_s
    phone_regex = Regexp.escape(PHONE_TEXT.strip)

    return true if current_text.match?(/#{phone_regex}/i)

    updated_text = current_text + "\n\n" + PHONE_TEXT.strip
    @message.update!(processed_text: updated_text)
    true
  end

  def remove_promo_text
    sleep 1
    @message.reload

    cleaned = exact_remove(@message.processed_text)
    cleaned = fuzzy_remove(cleaned)
    cleaned = remove_link_lines(cleaned) # <-- Новый шаг: удаление строк со ссылками
    cleaned = cleaned.gsub(/(\n\s*){2,}/, "\n\n")
    cleaned = cleaned.gsub(/^\s*?\n/m, "\n")
    cleaned = cleaned.gsub(/\A\n+|\n+\z/, '')

    @message.update!(processed_text: cleaned.strip)
    true
  end

  def exact_remove(text)
    PROMO_PATTERNS.reduce(text) do |current_text, pattern|
      regex = Regexp.escape(pattern).gsub(/\s+/, "\\s+")
      current_text.gsub(/#{regex}/im, "")
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
end
