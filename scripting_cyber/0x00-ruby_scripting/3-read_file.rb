require 'json'

def count_user_ids(path)
  # 1. Читаем файл и парсим JSON в массив хэшей Ruby
  file_content = File.read(path)
  data = JSON.parse(file_content)

  # 2. Создаем хэш-счетчик с дефолтным значением 0 для новых ключей
  id_counts = Hash.new(0)

  # 3. Перебираем каждый элемент и инкрементируем счетчик для конкретного userId
  data.each do |item|
    user_id = item['userId']
    id_counts[user_id] += 1 if user_id
  end

  # 4. Выводим результат в консоль в нужном формате
  id_counts.each do |user_id, count|
    puts "#{user_id}: #{count}"
  end
end
