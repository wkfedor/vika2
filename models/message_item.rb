# models/message_item.rb
class MessageItem < ActiveRecord::Base
  self.table_name = "message_items"
  has_many :sources, class_name: "MessageItemSource", foreign_key: :message_item_id
end
