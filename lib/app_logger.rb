# lib/logger.rb

module AppLogger
  def log_info(message)
    puts "[INFO] [#{Time.now}] #{message}"
  end

  def log_debug(message)
    puts "[DEBUG] [#{Time.now}] #{message}"
  end

  def log_error(exception, context: "")
    puts "[ERROR] [#{Time.now}] #{context}: #{exception.message}"
    puts exception.backtrace.join("\n") if exception.backtrace
  end

  module_function :log_info, :log_debug, :log_error
end
