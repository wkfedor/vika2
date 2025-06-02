# services/censor.rb

class Censor
  # Белый список пользователей по группам
  WHITELIST = {
    1551946392 => ["opt_zabaikalsk"],
    1628399582 => ["opt75"],
    2225744678 => ["nil", "opt75", "CHINA_LINE_MSK", "pirokindyk"], # nil → разрешает отправителей с sender_username = nil
    978474978 => ["Yuliya_Dorogan", "ke_7277","Vladsbogom96"]
  }.transform_values { |users| users.map(&:to_s).map(&:downcase) }

  def initialize(message_item)
    @message = message_item
  end

  def run
    puts "[CENSOR] 🔍 Начинаем проверку сообщения ID #{@message.id}..."

    text_preview = @message.processed_text ? @message.processed_text.truncate(100) : "Нет текста"

    puts "[CENSOR] 📝 Текст сообщения: #{text_preview}"

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
end
