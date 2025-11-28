require 'json'
require 'csv'
require 'yaml'
require_relative 'item_container'
require_relative 'logger_manager'

module Tarnovetskyi
  class Cart
    # Підключаємо наш модуль
    include ItemContainer
    # Підключаємо Enumerable для перебору товарів 
    include Enumerable

    attr_accessor :items

    def initialize
      @items = []
      Tarnovetskyi::LoggerManager.log_processed_file("Cart initialized")
    end

    # Реалізація each для Enumerable (обов'язково!) 
    def each(&block)
      @items.each(&block)
    end

    # Метод генерації тестових даних 
    def generate_test_items(count)
      count.times do
        item = Tarnovetskyi::Item.generate_fake
        add_item(item)
      end
      puts "#{count} test items generated."
    end

    # --- Методи збереження ---

    # Збереження в JSON 
    def save_to_json(filename)
      File.open(filename, 'w') do |f|
        # Перетворюємо кожен item на хеш перед збереженням
        f.write(@items.map(&:to_h).to_json)
      end
      Tarnovetskyi::LoggerManager.log_processed_file("Saved to JSON: #{filename}")
    end

    # Збереження в CSV 
    def save_to_csv(filename)
      CSV.open(filename, 'w') do |csv|
        # Заголовки (беремо з першого елемента, якщо він є)
        headers = @items.first&.to_h&.keys || []
        csv << headers
        
        @items.each do |item|
          csv << item.to_h.values
        end
      end
      Tarnovetskyi::LoggerManager.log_processed_file("Saved to CSV: #{filename}")
    end

    # Збереження в YAML 
    def save_to_yml(filename)
      File.open(filename, 'w') do |f|
        f.write(@items.map(&:to_h).to_yaml)
      end
      Tarnovetskyi::LoggerManager.log_processed_file("Saved to YAML: #{filename}")
    end
    
    # Збереження в текстовий файл (простий формат) 
    def save_to_file(filename)
       File.open(filename, 'w') do |f|
         @items.each { |item| f.puts item.to_s }
       end
       Tarnovetskyi::LoggerManager.log_processed_file("Saved to TXT: #{filename}")
    end
  end
end