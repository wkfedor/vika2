# services/quality_control.rb

class QualityControl
  def initialize(message_item)
    @message = message_item
  end

  def approve
    puts "[ОТК] Проверка сообщения ID #{@message.id}..."
    @message.reload.approve_for_sending!
    @message.save!
    puts "[ОТК] ✅ Сообщение переведено в статус 'ready_to_send'"
  end
end
