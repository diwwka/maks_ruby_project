require_relative 'lib/app_config_loader'
require_relative 'lib/logger_manager'
require_relative 'lib/database_connector' # <--- Підключаємо конектор

# Ініціалізація
config_loader = Tarnovetskyi::AppConfigLoader.new
config_loader.load_libs(Dir.pwd)
config_data = config_loader.config('config/default_config.yaml', 'config')
Tarnovetskyi::LoggerManager.init_logger(config_data)

puts "--- Тестування DatabaseConnector ---"

# 1. Створення конектора
connector = Tarnovetskyi::DatabaseConnector.new(config_data)

# 2. Підключення
puts "Підключаємося до БД..."
connector.connect_to_database

# 3. Перевірка
if connector.db
  puts "Підключення успішне! Об'єкт БД: #{connector.db}"
  puts "Перевірте папку db/ - там мав з'явитися файл local_database.sqlite"
else
  puts "Помилка підключення!"
end

# 4. Закриття
connector.close_connection
puts "З'єднання закрито."