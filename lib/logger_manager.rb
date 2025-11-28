require 'logger'
require 'fileutils'

module Tarnovetskyi 
  class LoggerManager
    # Використовуємо class << self, щоб методи були доступні без створення екземпляра (static methods)
    class << self
      attr_reader :logger

      # Метод ініціалізації логера 
      def init_logger(config)
        # Отримуємо налаштування з конфігу (ключ 'logging')
        logging_config = config['logging']
        
        # 1. Створюємо директорію для логів, якщо її немає 
        log_dir = logging_config['directory']
        FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)

        # 2. Визначаємо шлях до файлу логів 
        # Беремо application_log з секції files
        log_file_name = logging_config['files']['application_log']
        log_file_path = File.join(log_dir, log_file_name)

        # 3. Створюємо об'єкт Logger
        @logger = Logger.new(log_file_path)

        # 4. Встановлюємо рівень логування 
        level_str = logging_config['level']
        # Перетворюємо рядок "DEBUG" у константу Logger::DEBUG
        @logger.level = Logger.const_get(level_str.upcase)

        # Налаштування формату виводу (опціонально, для краси)
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
        end
        
        @logger.info("Logger initialized successfully.")
      end

      # Метод для логування звичайних дій 
      def log_processed_file(message)
        # Перевірка, чи логер ініціалізований
        if @logger
          @logger.info(message)
        else
          puts "LOGGER NOT STARTED: #{message}"
        end
      end

      # Метод для логування помилок 
      def log_error(error_message)
        if @logger
          @logger.error(error_message)
        else
          puts "LOGGER ERROR: #{error_message}"
        end
      end
    end
  end
end