# main.rb
require_relative 'lib/app_config_loader'

# Ініціалізуємо завантажувач
config_loader = Tarnovetskyi::AppConfigLoader.new

# 1. Автоматичне підключення бібліотек [cite: 689]
# Передаємо поточну директорію як корінь
config_loader.load_libs(Dir.pwd)

# 2. Завантаження конфігурацій [cite: 691]
# Вказуємо шлях до default_config.yaml та папки config
config_data = config_loader.config('config/default_config.yaml', 'config')

puts "--- Перевірка Конфігурації ---"

# 3. Перевірка завантаження (вивід JSON) [cite: 693]
config_loader.pretty_print_config_data
