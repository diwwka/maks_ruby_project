# main.rb
require_relative 'lib/app_config_loader'
require_relative 'lib/logger_manager'
require_relative 'lib/item'
require_relative 'lib/cart' # <--- Підключаємо Кошик

# Ініціалізація
config_loader = Tarnovetskyi::AppConfigLoader.new
config_loader.load_libs(Dir.pwd)
config_data = config_loader.config('config/default_config.yaml', 'config')
Tarnovetskyi::LoggerManager.init_logger(config_data)

puts "--- Тестування Кошика (Cart) ---"

# 1. Створюємо кошик
cart = Tarnovetskyi::Cart.new

# 2. Генеруємо тестові дані
cart.generate_test_items(5)

# 3. Перевірка method_missing (show_all_items)
puts "\n--- Вивід через show_all_items ---"
cart.show_all_items

# 4. Перевірка Enumerable (наприклад, сортування за ціною)
puts "\n--- Найдорожча книга ---"
# sort повертає масив, last бере останній (найдорожчий)
most_expensive = cart.sort.last 
puts most_expensive

# 5. Перевірка збереження файлів
puts "\n--- Збереження файлів ---"
# Створимо папку output, якщо її немає (хоча вона мала бути)
Dir.mkdir('output') unless Dir.exist?('output')

cart.save_to_json('output/items.json')
cart.save_to_csv('output/items.csv')
cart.save_to_yml('output/items.yml')

puts "Перевірте папку output/ - там мають бути 3 файли!"