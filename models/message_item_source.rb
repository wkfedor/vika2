# models/message_item_source.rb

class MessageItemSource < ActiveRecord::Base
  self.table_name = "message_item_sources"

  # Связь с MessageItem
  belongs_to :message_item, class_name: "MessageItem", foreign_key: :message_item_id

  # Связь с Message
  belongs_to :message, class_name: "Message"
end
