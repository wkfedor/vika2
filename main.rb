# main.rb
require 'active_record'
require 'json'
require_relative 'config/boot' # загрузка ActiveRecord и моделей

log_info("🚀 Запуск процессора сообщений...")

worker = MessagePollerWorker.new
worker.run
