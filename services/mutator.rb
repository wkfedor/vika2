# frozen_string_literal: true

class Mutator
  PHONE_TEXT = "\n\nЗвоните 89509901103"

  # Список рекламных фраз, которые нужно убрать из сообщений
  PROMO_PATTERNS = [
    "Пиши в директ — сделаем выгодное предложение! ⚡️\nВ наличии на Малиновского 25/2\nКутузова 1стр105",
    "Отправка догрузом по всем городам от Забайкальска до Омска БЕСПЛАТНО!",
    "Отправка до Читы машина БЕСПЛАТНО!",
    "Комиссия агента 10 % от стоимости товара.",
    "Бесплатная доставка по РФ!",
    "📲Для заказа свяжитесь с менеджером: +79854485447",
    "В наличии в Красноярске",
    "Малиновского 25/2",
    "Кутузова 1стр105",
    "89955775669",
    "Пиши в директ — сделаем выгодное предложение!",
    "💬 Пиши в директ — сделаем выгодное предложение!",
    "⚡",
    "Наш адрес Новопоселковая 11с5",
    "****+79955775669****",
    "****+79697776163**",

    # 🔥 Новые паттерны для удаления:
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
    "📲Для заказа свяжитесь с менеджером: +79854485447"
  ].freeze

  # Порог похожести для fuzzy-удаления (от 0.0 до 1.0)
  SIMILARITY_THRESHOLD = 0.85

  def initialize(message_item)
    @message = message_item
  end

  # 🏁 Основной метод: изменяет текст сообщения
  # - Добавляет телефон
  # - Убирает рекламные фразы
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

  # 📞 Добавляет телефон к концу текста, если его ещё нет
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

  # 🧹 Удаляет рекламные фразы из текста
  def remove_promo_text
    sleep 1
    @message.reload

    # Шаг 1: Точные удаления
    cleaned = exact_remove(@message.processed_text)

    # Шаг 2: Fuzzy-удаление
    cleaned = fuzzy_remove(cleaned)

    # Шаг 3: Чистка пустых строк и лишних переносов
    cleaned = cleaned.gsub(/(\n\s*){2,}/, "\n\n") # более 2 переносов → один
    cleaned = cleaned.gsub(/^\s*?\n/m, "\n")     # пустые строки → заменить на одну
    cleaned = cleaned.gsub(/\A\n+|\n+\z/, '')     # убрать начальные/конечные переносы

    # Шаг 4: Сохраняем очищенный текст
    @message.update!(processed_text: cleaned.strip)
    true
  end

  # 🔍 Точное удаление рекламных фраз с гибкостью к переносам строк
  def exact_remove(text)
    PROMO_PATTERNS.reduce(text) do |current_text, pattern|
      regex = Regexp.escape(pattern).gsub(/\s+/, "\\s+")
      current_text.gsub(/#{regex}/im, "")
    end
  end

  # 🔍 Fuzzy удаление: если текст похож на рекламную фразу, тоже удаляем
  def fuzzy_remove(text)
    PROMO_PATTERNS.reduce(text) do |current_text, pattern|
      if similar?(current_text, pattern, threshold: SIMILARITY_THRESHOLD)
        current_text.gsub(/#{Regexp.escape(pattern)}/i, "")
      else
        current_text
      end
    end.strip
  end

  # 🧠 Простая проверка похожести двух строк (по количеству совпадающих слов)
  def similar?(text, pattern, threshold:)
    text_words = text.downcase.gsub(/[^\w\s]/, "").split
    pattern_words = pattern.downcase.gsub(/[^\w\s]/, "").split

    common_words = (text_words & pattern_words).size.to_f / pattern_words.size.to_f
    common_words >= threshold
  end
end
