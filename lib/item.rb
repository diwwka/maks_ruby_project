# Модуль (простір імен)
module Tarnovetskyi
  # Клас для представлення одиниці товару (книги)
  class Item
    # 2. Атрибути класу: (Мінімум 5, включаючи image_path)
    attr_accessor :name, :price, :description, :category, :image_path 
    
    # Вимоги до конструктора та логування ми реалізуємо пізніше,
    # коли буде реалізовано LoggerManager та ItemCollection.
    
    # Реалізуємо базовий конструктор з опціональними атрибутами
    def initialize(params = {})
      # Використовуємо значення за замовчуванням
      @name = params[:name] || 'Немає назви'
      @price = params[:price] || 0
      @description = params[:description] || 'Немає опису'
      @category = params[:category] || 'Немає категорії'
      # image_path є обов'язковим атрибутом [cite: 378, 383]
      @image_path = params[:image_path] || 'media/default.jpg' 
    end
    
    # 4. Методи to_s, to_h, inspect
    
    # to_s: Формує рядок для виводу всіх атрибутів [cite: 399]
    def to_s
      "Назва: #{@name}, Ціна: #{@price}, Категорія: #{@category}"
    end
    
    # to_h: Формує хеш на базі атрибутів класу (динамічний підхід) [cite: 400]
    def to_h
      # Використовуємо instance_variables для динамічного вилучення атрибутів
      Hash[instance_variables.map { |var| [var.to_s.delete('@').to_sym, instance_variable_get(var)] }]
    end
    
    # inspect: Відображає інформацію про об'єкт у зручному форматі [cite: 401]
    def inspect
      "#<MaksApp::Item:0x#{object_id.to_s(16)} #{to_h}>"
    end
  end
end