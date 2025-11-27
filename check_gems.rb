# check_gems.rb

# 1. Завантажуємо Bundler (обов'язково для використання гемів із Gemfile)
require 'bundler/setup'

# 2. Завантажуємо Nokogiri
require 'nokogiri'

# 3. Завантажуємо HTTParty
require 'httparty'

# 4. Виводимо версії Nokogiri та HTTParty для перевірки
puts "--- Перевірка Бібліотек ---"
puts "Nokogiri версія: #{Nokogiri::VERSION}"
puts "HTTParty версія: #{HTTParty::VERSION}"

# 5. Перевіряємо, чи доступний RuboCop (якщо він встановлений)
begin
  require 'rubocop'
  puts "RuboCop версія: #{RuboCop::Version.version}"
rescue LoadError
  puts "RuboCop не знайдено, але це може бути очікувано, якщо він не потрібен для запуску."
end

puts "--- Перевірка Успішна! ---"
