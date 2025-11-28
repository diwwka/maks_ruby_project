require 'zip'
require_relative 'logger_manager'

module Tarnovetskyi
  class Archiver
    # Метод класу для архівації
    def self.archive(input_dirs, output_zip_path)
      # Видаляємо старий архів
      File.delete(output_zip_path) if File.exist?(output_zip_path)
      # Створюємо архів 
      Zip::File.open(output_zip_path, create: true) do |zipfile|
        
        # Проходимо по кожній папці зі списку
        input_dirs.each do |root_dir|
          
          # Перевіряємо, чи папка взагалі існує
          next unless Dir.exist?(root_dir)

          # Знаходимо всі файли всередині
          Dir.glob(File.join(root_dir, '**', '*')).each do |file|
            
            # Тепер ми залишаємо кореневу папку, щоб у архіві була структура:
            #   output/items.csv
            #   media/category/img.jpg
            # Це запобігає конфліктам імен.
            
            zipfile.add(file, file)
          end
        end
      end

      Tarnovetskyi::LoggerManager.log_processed_file("Archived #{input_dirs} into #{output_zip_path}")
      puts "  -> Архів створено: #{output_zip_path}"
    rescue StandardError => e
      Tarnovetskyi::LoggerManager.log_error("Archiving failed: #{e.message}")
      puts "  -> Помилка архівації: #{e.message}"
    end
  end
end