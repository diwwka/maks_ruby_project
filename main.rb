# main.rb
require_relative 'lib/app_config_loader'
require_relative 'lib/logger_manager'
require_relative 'lib/item' # <--- Підключаємо наш новий клас

# 1. Ініціалізація
config_loader = Tarnovetskyi::AppConfigLoader.new
config_loader.load_libs(Dir.pwd)
config_data = config_loader.config('config/default_config.yaml', 'config')

Tarnovetskyi::LoggerManager.init_logger(config_data)

puts "--- Тестування Класу Item ---"

# 1. Створення звичайного об'єкта
item1 = Tarnovetskyi::Item.new(name: "Ruby Programming", price: 50.0, category: "IT")
puts "Створено: #{item1}"

# 2. Створення фейкового об'єкта
puts "\n--- Генерація Fake Item ---"
fake_item = Tarnovetskyi::Item.generate_fake
puts fake_item.inspect

# 3. Перевірка блоку update
puts "\n--- Оновлення Item ---"
item1.update do |i|
  i.price = 99.99
  i.name = "Advanced Ruby"
end
puts "Оновлено: #{item1}"

# 4. Перевірка логів
puts "\nПеревірте logs/app.log - там мають бути записи про створення та оновлення."