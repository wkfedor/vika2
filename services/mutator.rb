# services/mutator.rb

class Mutator
  PHONE_TEXT = "\n\nЗвоните 89509901103"

  PROMO_TEXT_TO_REMOVE = <<~TEXT
Пиши в директ — сделаем выгодное предложение! ⚡️
В наличии на Малиновского 25/2
Кутузова 1стр105
  TEXT

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
    @message.update!(processed_text: @message.processed_text + PHONE_TEXT)
    true
  end

  def remove_promo_text
    sleep 1
    @message.reload
    cleaned = @message.processed_text.gsub(PROMO_TEXT_TO_REMOVE.strip, "").strip
    @message.update!(processed_text: cleaned)
    true
  end
end
