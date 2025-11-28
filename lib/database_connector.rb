require 'sqlite3'
require_relative 'logger_manager'

module Tarnovetskyi
  class DatabaseConnector
    attr_reader :db

    def initialize(config)
      # Отримуємо секцію database_config з повного конфігу
      @db_config = config['database_config']
      @db = nil
      Tarnovetskyi::LoggerManager.log_processed_file("DatabaseConnector initialized")
    end

    # Основний метод підключення 
    def connect_to_database
      db_type = @db_config['database_type']
      
      case db_type
      when 'sqlite'
        connect_to_sqlite
      when 'mongodb'
        connect_to_mongodb
      else
        Tarnovetskyi::LoggerManager.log_error("Unsupported database type: #{db_type}")
        raise "Unsupported database type: #{db_type}"
      end
    end

    # Закриття з'єднання 
    def close_connection
      if @db && !@db.closed?
        @db.close
        Tarnovetskyi::LoggerManager.log_processed_file("Database connection closed")
      end
    end

    private

    # Підключення до SQLite 
    def connect_to_sqlite
      sqlite_config = @db_config['sqlite_database']
      db_file = sqlite_config['db_file']
      
      # Створюємо папку для БД, якщо її немає (безпека)
      dir = File.dirname(db_file)
      Dir.mkdir(dir) unless Dir.exist?(dir)

      begin
        # Відкриваємо (або створюємо) базу даних
        @db = SQLite3::Database.new(db_file)
        
        # Створюємо таблицю items, якщо її ще немає (ініціалізація структури)
        create_tables_sqlite
        
        Tarnovetskyi::LoggerManager.log_processed_file("Connected to SQLite: #{db_file}")
      rescue SQLite3::Exception => e
        Tarnovetskyi::LoggerManager.log_error("SQLite connection error: #{e.message}")
        raise e
      end
    end

    # Заглушка для MongoDB [cite: 48]
    def connect_to_mongodb
      Tarnovetskyi::LoggerManager.log_processed_file("MongoDB connection requested (not implemented in this lab scope)")
      # Тут був би код для Mongo::Client.new(...)
    end
    
    # Допоміжний метод для створення таблиці (щоб було куди зберігати)
    def create_tables_sqlite
      @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          description TEXT,
          category TEXT,
          image_path TEXT
        );
      SQL
    end
  end
end