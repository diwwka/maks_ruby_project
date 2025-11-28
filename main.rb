# main.rb
require_relative 'lib/app_config_loader'
# Підключаємо новий файл (хоча load_libs мав би зробити це сам, але для надійності)
require_relative 'lib/logger_manager' 

# 1. Ініціалізація
config_loader = Tarnovetskyi::AppConfigLoader.new
config_loader.load_libs(Dir.pwd)
config_data = config_loader.config('config/default_config.yaml', 'config')

# 2. Налаштування Логування (НОВЕ)
puts "--- Ініціалізація Логера ---"
# Передаємо весь хеш конфігурації, клас сам знайде ключ 'logging'
Tarnovetskyi::LoggerManager.init_logger(config_data)

# 3. Тестовий запис у лог
Tarnovetskyi::LoggerManager.log_processed_file("Програма успішно запустилася!")
Tarnovetskyi::LoggerManager.log_error("Це тестовий запис помилки (не хвилюйтесь).")

puts "Логування завершено. Перевірте файл logs/app.log"

# (Вивід JSON поки можна закоментувати, щоб не засмічувати екран)
# config_loader.pretty_print_config_data