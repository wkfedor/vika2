# frozen_string_literal: true

class Mutator
  PHONE_TEXT = "\n\nЗвоните 89509901103"

  # Список рекламных фраз, которые нужно убрать из сообщений
  PROMO_PATTERNS = [
    "Пиши в директ — сделаем выгодное предложение! ⚡️\nВ наличии на Малиновского 25/2\nКутузова 1стр105",
    "Отправка догрузом по всем городам от Забайкальска до Омска БЕСПЛАТНО!",
    "Отправка до Читы машина БЕСПЛАТНО!",
    "Комиссия агента 10 % от стоимости товара.",
    "Бесплатная доставка по РФ!"
  ].freeze

  # Порог похожести для fuzzy-удаления (от 0.0 до 1.0)
  SIMILARITY_THRESHOLD = 0.75

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

  # 📞 Добавляет телефон к концу текста
  def add_phone_number
    sleep 1
    @message.reload
    @message.update!(processed_text: @message.processed_text + PHONE_TEXT)
    true
  end

  # 🧹 Удаляет рекламные фразы из текста
  def remove_promo_text
    sleep 1
    @message.reload

    # Шаг 1: Удаляем точные совпадения
    cleaned = exact_remove(@message.processed_text)

    # Шаг 2: Удаляем похожие фразы
    cleaned = fuzzy_remove(cleaned)

    # Шаг 3: Сохраняем очищенный текст
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
