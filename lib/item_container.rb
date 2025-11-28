module Tarnovetskyi
  module ItemContainer
    module ClassMethods
      # Метод класу: повертає інформацію про клас (версію) [cite: 103]
      def class_info
        "Class: #{self.name}, Version: 1.0"
      end

      # Лічильник об'єктів (спрощена версія, можна розширити)
      def items_count
        @items_count ||= 0
      end
    end

    module InstanceMethods
      # a. add_item: Додає товар до колекції [cite: 96]
      def add_item(item)
        @items << item
        # Використовуємо LoggerManager з твого простору імен
        Tarnovetskyi::LoggerManager.log_processed_file("Item added: #{item.name}")
      end

      # b. remove_item: Видаляє товар з колекції [cite: 97]
      def remove_item(item)
        @items.delete(item)
        Tarnovetskyi::LoggerManager.log_processed_file("Item removed: #{item.name}")
      end

      # c. delete_items: Видаляє всі товари (очищення) [cite: 98-99]
      def delete_items
        @items.clear
        Tarnovetskyi::LoggerManager.log_processed_file("All items deleted from cart")
      end

      # d. method_missing: Магія Ruby [cite: 100]
      # Якщо викликати метод show_all_items, він спрацює через цей перехоплювач
      def method_missing(method_name, *args, &block)
        if method_name == :show_all_items
          puts "--- All Items in Cart ---"
          @items.each { |item| puts item }
          puts "-----------------------"
        else
          super
        end
      end
      
      # Важливо для method_missing: повідомляти Ruby, що ми підтримуємо цей метод
      def respond_to_missing?(method_name, include_private = false)
        method_name == :show_all_items || super
      end
    end

    # Callback-метод: Запускається автоматично при include [cite: 86-92]
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end
  end
end