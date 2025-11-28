require_relative 'lib/engine'

puts "--- ЗАПУСК ПРОГРАМИ (MaksApp / Tarnovetskyi) ---"

begin
  # Створюємо і запускаємо Двигун
  engine = Tarnovetskyi::Engine.new
  engine.run
  
  puts "\nПрограма успішно виконала роботу!"
  puts "Перевірте папку output/ та базу даних db/local_database.sqlite"
rescue StandardError => e
  puts "Виникла помилка під час запуску: #{e.message}"
end