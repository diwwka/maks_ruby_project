require 'yaml'
require 'json'
require 'erb'
require 'date' # Приклад системної бібліотеки

module Tarnovetskyi
  class AppConfigLoader
    attr_reader :config_data

    def initialize
      @config_data = {}
    end

    # Метод config: Завантажує конфігурацію 
    # Приймає шлях до основного файлу і директорію з іншими YAML
    def config(default_config_path, yaml_config_dir = nil)
      # 1. Завантажити основні дані 
      @config_data = load_default_config(default_config_path)

      # 2. Завантажити додаткові файли, якщо директорія вказана 
      if yaml_config_dir && Dir.exist?(yaml_config_dir)
        additional_configs = load_config(yaml_config_dir)
        @config_data.merge!(additional_configs)
      end

      # 3. Обробити блок, якщо він переданий 
      yield(@config_data) if block_given?

      @config_data
    end

    # Метод pretty_print_config_data: Вивід у JSON 
    def pretty_print_config_data
      puts JSON.pretty_generate(@config_data)
    end

    # Метод для підключення бібліотек 
    def load_libs(root_dir)
      # 1. Підключення системних бібліотек (приклад: date, json, yaml вже підключені вище) 
      # Тут можна додати масив, якщо потрібно щось специфічне
      
      # 2. Підключення локальних бібліотек з папки lib (в завданні написано libs, але ми використовуємо lib) 
      # Використовуємо Dir.glob для пошуку всіх .rb файлів
      lib_path = File.join(root_dir, 'lib', '**', '*.rb')
      
      Dir.glob(lib_path).each do |file|
        # Пропускаємо сам файл завантажувача та main.rb, щоб не викликати циклічне завантаження або помилки
        next if file == __FILE__ || file.end_with?('main.rb')
        
        require_relative file
        # puts "Підключено: #{file}" # Для дебагу
      end
    end

    private

    # Приватний метод завантаження основного конфігу з ERB 
    def load_default_config(path)
      return {} unless File.exist?(path)
      
      # Спочатку обробляємо ERB (для динамічних шляхів), потім YAML
      file_content = File.read(path)
      erb_result = ERB.new(file_content).result
      YAML.safe_load(erb_result, aliases: true) || {}
    end

    # Приватний метод завантаження всіх YAML з директорії 
    def load_config(dir)
      result = {}
      # Знаходимо всі .yaml або .yml файли
      Dir.glob(File.join(dir, '*.{yaml,yml}')).each do |file|
        # Пропускаємо default_config, бо він вже завантажений
        next if file.include?('default_config.yaml')

        data = YAML.load_file(file, aliases: true)
        result.merge!(data) if data
      end
      result
    end
  end
end