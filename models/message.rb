# models/message.rb
class Message < ActiveRecord::Base
  self.table_name = "messages"

  def self.pending
    where(sent_status: false)
      .order(:id)
      .to_a
  end
end
