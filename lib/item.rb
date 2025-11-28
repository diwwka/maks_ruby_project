require 'faker'
require_relative 'logger_manager'

module Tarnovetskyi
  class Item
    # 9. Розширення функціональності: Comparable (для порівняння об'єктів, наприклад, за ціною) [cite: 77]
    include Comparable

    # 5. Геттери та сеттери [cite: 63-64]
    attr_accessor :name, :price, :description, :category, :image_path

    # 3. Метод initialize [cite: 48-58]
    def initialize(params = {})
      @name = params[:name] || 'Unknown'
      @price = params[:price] || 0.0
      @description = params[:description] || 'No description'
      @category = params[:category] || 'Uncategorized'
      @image_path = params[:image_path]

      # Підтримка блоку для налаштування [cite: 50-56]
      yield(self) if block_given?

      # Валідація обов'язкового атрибуту (за логікою image_path важливий)
      # Але за умовою ми просто встановлюємо дефолт, якщо не передано, або залишаємо nil
      
      # 10. Логування ініціалізації [cite: 78-83]
      Tarnovetskyi::LoggerManager.log_processed_file("Initialized Item: #{@name}")
    end

    # 4. Метод to_s [cite: 60]
    def to_s
      "Item: #{@name} | Price: #{@price} | Category: #{@category}"
    end

    # 4. Метод to_h (динамічний) [cite: 61]
    def to_h
      instance_variables.each_with_object({}) do |var, hash|
        # Видаляємо символ '@' з назви змінної
        key = var.to_s.delete('@').to_sym
        hash[key] = instance_variable_get(var)
      end
    end

    # 4. Метод inspect [cite: 62]
    def inspect
      "#<Tarnovetskyi::Item:0x#{object_id.to_s(16)} #{to_h}>"
    end

    # 7. Метод info (alias для to_s) [cite: 72-74]
    alias_method :info, :to_s

    # 6. Метод update (зміна через блок) [cite: 65-71]
    def update
      yield(self) if block_given?
      Tarnovetskyi::LoggerManager.log_processed_file("Updated Item: #{@name}")
    end

    # 9. Метод <=> для Comparable (порівнюємо за ціною) [cite: 77]
    def <=>(other)
      return nil unless other.is_a?(Item)
      @price <=> other.price
    end

    # 8. Метод self.generate_fake (Клас-метод) [cite: 75-76]
    def self.generate_fake
      new(
        name: Faker::Book.title,
        price: Faker::Commerce.price(range: 10.0..100.0),
        description: Faker::Lorem.sentence,
        category: Faker::Book.genre,
        image_path: "media/fake_#{Faker::Alphanumeric.alpha(number: 5)}.jpg"
      )
    end
  end
end