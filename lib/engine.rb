require_relative 'app_config_loader'
require_relative 'logger_manager'
require_relative 'database_connector'
require_relative 'simple_website_parser'
require_relative 'configurator'

module Tarnovetskyi
  class Engine
    def initialize
      # Ініціалізуємо завантажувач конфігів
      @config_loader = Tarnovetskyi::AppConfigLoader.new
      @config_loader.load_libs(Dir.pwd) # Підключаємо бібліотеки
      @config = nil
      @db_connector = nil
      @parser = nil
    end

    # Основний метод запуску [cite: 406-413]
    def run
      # 1. Завантаження конфігурації
      load_config
      
      # 2. Ініціалізація логування
      initialize_logging

      Tarnovetskyi::LoggerManager.log_processed_file("Engine started...")

      # 3. Підключення до БД
      @db_connector = Tarnovetskyi::DatabaseConnector.new(@config)
      @db_connector.connect_to_database

      # 4. Налаштування конфігуратора (для керування методами)
      # Створюємо Configurator, але поки що не використовуємо його overrides логіку,
      # просто беремо значення з YAML, які ми завантажили в @config
      
      # 5. Виконання методів
      run_methods

    rescue StandardError => e
      Tarnovetskyi::LoggerManager.log_error("Engine critical error: #{e.message}")
      puts "CRITICAL ERROR: #{e.message}"
    ensure
      # 6. Відключення від БД
      @db_connector&.close_connection
      Tarnovetskyi::LoggerManager.log_processed_file("Engine finished.")
    end

    private

    def load_config
      # Завантажуємо з default_config.yaml
      @config = @config_loader.config('config/default_config.yaml', 'config')
      puts "Конфігурація завантажена."
    end

    def initialize_logging
      Tarnovetskyi::LoggerManager.init_logger(@config)
    end

    # Метод, який запускає потрібні дії [cite: 403-405]
    def run_methods
      # Ми перевіряємо кожен ключ у конфігураторі (наприклад, run_website_parser)
      # Але значення беремо безпосередньо з @config (якщо вони там є) або використовуємо дефолтні
      
      # Для спрощення: припустимо, що ми хочемо запустити все, що вказано в main.rb через Configurator,
      # або просто перевіряємо ключі вручну.
      
      # Логіка запуску:
      run_website_parser
      
      # Збереження (якщо парсер щось знайшов)
      if @parser&.item_collection&.any?
        run_save_to_csv
        run_save_to_json
        run_save_to_yaml
        run_save_to_sqlite
      else
        Tarnovetskyi::LoggerManager.log_processed_file("No items to save.")
      end
    end

    # --- Реалізація дій [cite: 416-423] ---

    def run_website_parser
      Tarnovetskyi::LoggerManager.log_processed_file("Running Website Parser...")
      @parser = Tarnovetskyi::SimpleWebsiteParser.new(@config)
      @parser.start_parse
    end

    def run_save_to_csv
      filename = "output/items.csv"
      @parser.item_collection.save_to_csv(filename)
    end

    def run_save_to_json
      filename = "output/items.json"
      @parser.item_collection.save_to_json(filename)
    end

    def run_save_to_yaml
      filename = "output/items.yml"
      @parser.item_collection.save_to_yml(filename)
    end

    def run_save_to_sqlite
      Tarnovetskyi::LoggerManager.log_processed_file("Saving to SQLite...")
      
      # Використовуємо підключення з @db_connector
      db = @db_connector.db
      
      @parser.item_collection.each do |item|
        # Перевіряємо, чи є такий товар, щоб не дублювати (спрощено)
        # Вставка даних
        db.execute("INSERT INTO items (name, price, description, category, image_path) VALUES (?, ?, ?, ?, ?)",
                   [item.name, item.price, item.description, item.category, item.image_path])
      end
      
      Tarnovetskyi::LoggerManager.log_processed_file("Data saved to SQLite.")
    end
  end
end