# services/censor.rb

class Censor
  # Белый список пользователей по группам
  WHITELIST = {
    1551946392 => ["opt_zabaikalsk", "trusted_user"]
  }.transform_values { |users| users.map(&:downcase) }

  def initialize(message_item)
    @message = message_item
  end

  def run
    puts "[CENSOR] 🔍 Начинаем проверку сообщения ID #{@message.id}..."
    puts "[CENSOR] 📝 Текст сообщения: #{@message.processed_text.truncate(100)}"

    if check_sender_whitelist
      puts "[CENSOR] ✅ Сообщение из доверенной группы — цензура пропущена"
      return true
    else
      puts "[CENSOR] ❌ Отправитель не в белом списке или группа не допускает исключения"
      return false
    end
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

    # Получаем все пары (group_id, sender_username)
    related_messages = Message.where(id: related_message_ids).pluck(:group_id, :sender_username)

    if related_messages.empty?
      puts "[CENSOR] ⚠️ Нет данных о группах или отправителях"
      return false
    end

    puts "[CENSOR] 🔎 Проверяем каждое сообщение..."

    related_messages.each do |group_id, sender|
      sender_down = sender.to_s.downcase

      if WHITELIST.key?(group_id)
        allowed_users = WHITELIST[group_id]
        puts "[CENSOR] 🧭 Группа #{group_id} — есть в белом списке"

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
end
