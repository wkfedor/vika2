# config/boot.rb
require 'active_record'
require 'logger'
require_relative '../models/message'
require_relative '../models/message_item'
require_relative '../models/message_item_source'
require_relative '../models/message_source'

# Подключение к БД
db_config = YAML.load_file('config/database.yml')['development']
ActiveRecord::Base.establish_connection(db_config)
