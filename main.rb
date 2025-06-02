# main.rb

$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
require 'app_logger'
require 'active_record'
require 'json'
require_relative 'config/boot' # загрузка ActiveRecord и моделей
require_relative 'workers/message_poller_worker'
require_relative 'services/message_processor_worker'

puts "[MAIN] 🚀 Запуск MessagePollerWorker..."
poller = MessagePollerWorker.new
Thread.new { poller.run }

#puts "[MAIN] 🚀 Запуск MessageProcessorWorker..."   # для работы
#processor = MessageProcessorWorker.new
#Thread.new { processor.run }

processor = MessageProcessorWorker.new(message_ids:  [271,623,267,600,601]) # для отладки
Thread.new { processor.run }

puts "[MAIN] 🔁 Все процессы запущены, ожидание завершения..."
sleep
