# main.rb

$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
require 'app_logger'
require 'active_record'
require 'json'
require_relative 'config/boot' # загрузка ActiveRecord и моделей
require_relative 'workers/message_poller_worker'
require_relative 'services/message_processor_worker'

#puts "[MAIN] 🚀 Запуск MessagePollerWorker..."
#poller = MessagePollerWorker.new
#Thread.new { poller.run }

puts "[MAIN] 🚀 Запуск MessageProcessorWorker..."
#processor = MessageProcessorWorker.new
#Thread.new { processor.run }

processor = MessageProcessorWorker.new(message_ids: [180,181])
Thread.new { processor.run }

puts "[MAIN] 🔁 Все процессы запущены, ожидание завершения..."
sleep
