require_relative 'logger_manager'

module Tarnovetskyi
  class Configurator
    attr_reader :config

    # 1. Значення за замовчуванням 
    def initialize
      @config = {
        run_website_parser: 0,   # 0 - вимкнено, 1 - увімкнено
        run_save_to_csv: 0,
        run_save_to_json: 0,
        run_save_to_yaml: 0,
        run_save_to_sqlite: 0,   # Поки що 0
        run_save_to_mongodb: 0
      }
    end

    # 2. Метод configure для оновлення налаштувань 
    def configure(overrides = {})
      overrides.each do |key, value|
        if @config.key?(key)
          @config[key] = value
          Tarnovetskyi::LoggerManager.log_processed_file("Config updated: #{key} = #{value}")
        else
          puts "WARNING: Config key '#{key}' is not valid."
          Tarnovetskyi::LoggerManager.log_error("Attempt to set invalid config key: #{key}")
        end
      end
    end

    # 3. Доступні методи 
    def self.available_methods
      [
        :run_website_parser,
        :run_save_to_csv,
        :run_save_to_json,
        :run_save_to_yaml,
        :run_save_to_sqlite,
        :run_save_to_mongodb
      ]
    end
  end
end