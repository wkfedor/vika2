# services/censor.rb
class Censor
  SENDER_BLACKLIST = ["Dillertut", "wkfedor"]
  TEXT_BLACKLIST = ["пиши в директ", "сделаем выгодное предложение", "в наличии"]

  def initialize(message_item)
    @message = message_item
  end

  def run
    puts "[CENSOR] Проверяем сообщение ID #{@message.id}..."

    unless check_sender_blacklist
      puts "[CENSOR] ❌ Отправитель в черном списке"
      return false
    end

    unless check_text_blacklist
      puts "[CENSOR] ❌ Текст содержит запрещённые слова"
      return false
    end

    puts "[CENSOR] ✅ Сообщение прошло цензуру"
    true
  end

  private

  def check_sender_blacklist
    related_messages = MessageItemSource.where(message_item_id: @message.id).pluck(:message_id)
    senders = Message.where(id: related_messages).pluck(:sender_username)

    blocked = senders & SENDER_BLACKLIST
    return blocked.empty?
  end

  def check_text_blacklist
    return false if TEXT_BLACKLIST.any? { |word| @message.processed_text.downcase.include?(word) }
    true
  end
end
