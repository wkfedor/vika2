# main.rb
$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
require 'app_logger'
require 'active_record'
require 'json'
require_relative 'config/boot' # загрузка ActiveRecord и моделей

require_relative 'workers/message_poller_worker'


AppLogger.log_info("🚀 Запуск процессора сообщений...")

worker = MessagePollerWorker.new
worker.run
