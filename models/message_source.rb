# models/message_source.rb
class MessageSource < ActiveRecord::Base
  self.table_name = "message_sources"

  validates :source_type, presence: true
  validates :external_id, presence: true
  validates_uniqueness_of :external_id, scope: :source_type
end
