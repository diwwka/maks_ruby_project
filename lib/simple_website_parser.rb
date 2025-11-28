require 'mechanize'
require 'open-uri'
require_relative 'logger_manager'
require_relative 'item'
require_relative 'cart'

module Tarnovetskyi
  class SimpleWebsiteParser
    attr_reader :item_collection

    def initialize(config)
      @config = config
      # Налаштування парсингу беруться з секції 'web_scraping'
      @parser_config = config['web_scraping']
      
      # Ініціалізація Mechanize агента 
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Safari' # Прикидаємось браузером
      
      # Ініціалізація колекції (Кошика) [cite: 400]
      @item_collection = Tarnovetskyi::Cart.new
      
      Tarnovetskyi::LoggerManager.log_processed_file("Parser initialized with config")
    end

    def start_parse
      start_url = @parser_config['start_page']
      Tarnovetskyi::LoggerManager.log_processed_file("Start parsing from: #{start_url}")

      # Перевірка доступності [cite: 413]
      unless check_url_response(start_url)
        Tarnovetskyi::LoggerManager.log_error("Start URL is not accessible: #{start_url}")
        return
      end

      # Отримуємо сторінку через Mechanize
      page = @agent.get(start_url)
      
      # Отримуємо посилання на продукти
      product_links = extract_products_links(page)
      
      puts "Знайдено #{product_links.size} книг. Починаємо обробку..."

      # Проходимо по кожному посиланню і парсимо детальну сторінку
      # (Для тесту беремо лише перші 3, щоб не спамити сайт, потім прибереш .first(3))
      product_links.first(3).each do |link|
        # Перетворюємо відносне посилання на абсолютне
        full_link = page.uri.merge(link)
        parse_product_page(full_link)
        # Невелика пауза, щоб не блокували (етика парсингу)
        sleep(1)
      end
      
      Tarnovetskyi::LoggerManager.log_processed_file("Parsing finished. Total items: #{@item_collection.items.size}")
    end

    private

    # Витягує посилання на продукти зі сторінки каталогу [cite: 406]
    def extract_products_links(page)
      # Використовуємо селектор з конфігу (product_link_selector: "h3 a")
      selector = @parser_config['product_link_selector']
      page.search(selector).map { |link| link['href'] }
    end

    # Парсить детальну сторінку продукту [cite: 408]
    def parse_product_page(url)
      begin
        Tarnovetskyi::LoggerManager.log_processed_file("Processing page: #{url}")
        page = @agent.get(url)

        # Збираємо дані, використовуючи методи extract_...
        name = extract_product_name(page)
        price_str = extract_product_price(page)
        # Чистимо ціну від символу £
        price = price_str.gsub('£', '').to_f 
        description = extract_product_description(page)
        category = extract_product_category(page)
        image_url = extract_product_image_url(page)
        
        # Збереження зображення 
        saved_image_path = save_image(image_url, name, category)

        # Створення об'єкта Item
        item = Tarnovetskyi::Item.new(
          name: name,
          price: price,
          description: description,
          category: category,
          image_path: saved_image_path
        )

        # Додавання в кошик
        @item_collection.add_item(item)
        puts "  -> Додано: #{name}"

      rescue StandardError => e
        Tarnovetskyi::LoggerManager.log_error("Error parsing page #{url}: #{e.message}")
      end
    end

    # --- Методи витягування даних (Extractors) [cite: 409-412] ---

    def extract_product_name(page)
      # На детальній сторінці назва зазвичай в h1
      page.search("h1").text.strip
    end

    def extract_product_price(page)
      selector = @parser_config['product_price_selector']
      page.search(selector).text.strip
    end

    def extract_product_description(page)
      selector = @parser_config['product_description_selector']
      # description може не бути, тому перевіряємо
      element = page.search(selector).first
      element ? element.text.strip : "No description"
    end
    
    def extract_product_category(page)
      selector = @parser_config['product_category_selector']
      page.search(selector).text.strip
    end

    def extract_product_image_url(page)
        selector = @parser_config['product_image_selector']
        # Безпечне отримання елемента
        element = page.search(selector).first
        
        if element && element['src']
            rel_url = element['src']
            page.uri.merge(rel_url).to_s
        else
            # Повертаємо посилання на заглушку або nil, якщо картинку не знайдено
            Tarnovetskyi::LoggerManager.log_error("Image not found for page: #{page.uri}")
            "http://books.toscrape.com/media/cache/2c/da/2cdad67c44b002e7ead0cc35693c0e8b.jpg" # Дефолтна картинка
        end
    end

    # Перевірка URL [cite: 413]
    def check_url_response(url)
      begin
        # Mechanize head request
        @agent.head(url)
        true
      rescue Mechanize::ResponseCodeError
        false
      end
    end

    # Метод збереження зображення 
    def save_image(url, filename, category)
      # Очищення назви для файлу
      safe_filename = filename.gsub(/[^a-zA-Z0-9\-\_]/, '_').downcase
      safe_category = category.gsub(/[^a-zA-Z0-9\-\_]/, '_').downcase
      
      # Шлях: media/category/filename.jpg
      media_dir = @config['default']['media_dir']
      category_dir = File.join(media_dir, safe_category)
      
      # Створюємо папку категорії, якщо немає
      FileUtils.mkdir_p(category_dir)
      
      local_path = File.join(category_dir, "#{safe_filename}.jpg")
      
      # Завантаження (використовуємо agent для збереження сесії/cookies якщо треба)
      begin
        @agent.get(url).save(local_path)
        local_path
      rescue StandardError => e
        Tarnovetskyi::LoggerManager.log_error("Failed to download image: #{url}")
        "media/default.jpg"
      end
    end
  end
end