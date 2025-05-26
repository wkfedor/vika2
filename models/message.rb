# models/message.rb

class Message < ActiveRecord::Base
  self.table_name = "messages"

  # Связь с message_item_sources
  has_many :message_item_sources, class_name: "MessageItemSource", foreign_key: :message_id

  # Связь с message_items через источники
  has_many :message_items, through: :message_item_sources


  def self.pending
    where(sent_status: false)
      .order(:id)
      .to_a
  end
end
