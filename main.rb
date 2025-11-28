# main.rb
require_relative 'lib/app_config_loader'
require_relative 'lib/logger_manager'
require_relative 'lib/configurator' # <--- Підключаємо

# Ініціалізація
config_loader = Tarnovetskyi::AppConfigLoader.new
config_loader.load_libs(Dir.pwd)
config_data = config_loader.config('config/default_config.yaml', 'config')
Tarnovetskyi::LoggerManager.init_logger(config_data)

puts "--- Тестування Configurator ---"

# 1. Створення конфігуратора
app_config = Tarnovetskyi::Configurator.new
puts "Дефолтні налаштування: #{app_config.config}"

# 2. Зміна налаштувань
puts "\nЗмінюємо налаштування..."
app_config.configure(
  run_website_parser: 1,
  run_save_to_json: 1,
  run_save_to_csv: 1,
  run_fake_method: 1 # Це має викликати помилку/попередження
)

puts "Оновлені налаштування: #{app_config.config}"