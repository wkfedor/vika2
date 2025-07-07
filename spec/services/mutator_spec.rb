require_relative '../../services/mutator.rb'  # Подключаем тестируемый класс

RSpec.describe Mutator do # RSpec.describe создает контейнер для группы связанных тестов, Начинает тестовый блок для класса Mutator
  # Тестовые случаи здесь
  describe '#remove_promo_text' do  # создаёт ещё один подблок, относящийся к методу #remove_promo_text или Группирует тесты для метода remove_promo_text
    it 'удаляет рекламный текст' do   # создаёт отдельный тестовый случай ("spec").
      message = double("Message", id: 1, processed_text: "Текст с рекламой\nПиши в директ! +79940259324")
      #  создаёт mock объект , который имитирует экземпляр класса Message
      # Этот объект называется "Message" для наглядности, но на самом деле это просто фиктивный объект.
      allow(message).to receive(:reload) # говорит: "Разреши объекту message получать вызов метода :reload, но ничего не делай" или # Разрешает вызов метода reload без выполнения его реальной логики
      allow(message).to receive(:update!) #     Разрешает вызов метода update! у message.  Как и выше, метод будет вызываться, но не выполнит реального обновления в БД.


      mutator = Mutator.new(message) # Создаёт экземпляр класса Mutator, передавая ему наш фиктивный объект message.
      mutator.send(:remove_promo_text) # Вызывает приватный метод  #remove_promo_text у экземпляра mutator.

      expect(message).to have_received(:update!).with(hash_including(processed_text: "Текст с рекламой\nПиши в директ!"))
      # проверяет что @message.update!(processed_text: cleaned.strip) что на объекте меседж был вызван метод update с параметром processed_text содержащим "Текст с рекламой\nПиши в директ!"
    end
    it 'удаляет упоминание Telegram из текста' do
      message = double("Message", id: 2, processed_text: "Текст с рекламой\nОбратитесь для уточнения деталей @marat124 или звоните")
      allow(message).to receive(:reload)
      allow(message).to receive(:update!)

      mutator = Mutator.new(message)
      mutator.send(:remove_promo_text)

      expect(message).to have_received(:update!).with(hash_including(processed_text: "Текст с рекламой\nОбратитесь для уточнения деталей или звоните"))
    end
  end
end
