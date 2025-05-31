# vika2
вторая версия вики, более простая, но с явной практической целью 

описание прокета:
1) сущность сообщение
может быть в статусе: отправлено, ожидаю получение данных, новое.
готово к отправке - значит можем отправлят. у нас несколько групп, вк и тг например?
ожидает получение данных, допостим есть состовное сообщение и текста еще нет, может мы попали в этот момент? что делаем, ждем 10 сек. потом работаем как есть

2) таблица sender с информацией об отправки сообщений в различные группы

3) мутатор 
3.1) удалятор, удаляет не нужные рекламные блоки, вставки
3.2) добавлятор, добавляет мои вставки

4) цензор не берет рекласные посты, посты о дропшипенге, посты с авто

план работ:
1) для первой стадии, как можно быстрее, нужно постить мои сообщения в мой же чат.
оснавная цель сделать как можно быстнрее рабочий прототип и запустить его.  12 мая 2025 год

------------------------------------------------------------------------------------------------------------- 14 мая
у меня есть скрипт на питоне, который читает сообщения из телеграмма и отправляет сообщения в телеграмм.
я не знаю питон, поэтом у вторую часть я хочу сделать на руби. 
его задача
1) читать из базы сообщения, постоянно, в режими реального времени
2) определять пришло полностью сообщение или только его часть, если мы решили что часть(создаем новую сущность), возвращаемся к этому сообщеню через 10 сек.
3) если сообщение пришло полностю, то мы создаем новую сущность, в которой происходит цензурирование(класс цензор), вызываеться мутатор(удаляет часть сообщения, изменяет часть сообщения)
4) далее если все хорошо мы отправляем это новое сообщения используя эту сущность. скорее всего мы будем вызывать какой то питоновский скрипт который  это сделает

позже я буду использовать рельсы, но сейчас они мне ненужны, будут логи в базе. какое решение мне использовать сейчас? 
выбери 1 самый популярный вариант и опиши его, код пока не надо писать, просто в общем.

------------------------------------------------------------------------------------------------------------- 18мая
во вложении код проекта по копированию переделыванию и переотправки сообщений. вика2.
сейчас мы собираем из сообщения из меседж в message_items
проанализируй код и скажи по факту какие статусы могут быть у сообщения в message_items, не теоретически а то что сейчас в коде.


напиши код который будет запускаться паралельно основному процессу, его задача будет обрабатывать сообщения со статусом new
код должен использовать принцыпы ооп и солид
1)берем сообщения со статусом нью меняем статус на processing
1.1) в лог выводим информацию о сообщении ид, текст если есть, и то что поменяли статус
2) созадешь экзэмпляр класса цензор, в котором ты получаешь это сообщение из message_items
2.1) по порядку выызваються методы цензора, если хоть один вернет false статус меняем на censored_failed, если прошли то меняем на censored
2.2) в 1 из методов получи связанные сообщения из меседж и перебери имена sender_username если среди их есть список исключений(в методе сделай переменую, и в ней оправитель Dillertut или wkfedor) верни фелс
2.3) другой из методов проверит текст сообщения из message_items так же на слова исключения, если есть то метод вернет фелс а раз есть 1 фесл то цензор ставит статус censored_failed
3) дальеше подхватывает мутатор, сделай так же несколько методов, которые если не завершились аварийно возвращают всегда тру, 
3.1) 1 метод мутатора добавить в конец мой телефон, типа : "Звоните 89509901103"
3.2) 2 метод мутатора должен найти и удалить текст например "Пиши в директ — сделаем выгодное предложение! ⚡️
   В наличии на Малиновского 25/2
   Кутузова 1стр105"

то есть если он не нашел, метод должен вернуть тру, если он вывал в исключение то тогда фелс.
та же логика если все тру mutated если есть фелс то  mutation_failed

обязательно на каждом пункте пиши данные в консоль, что бы было понятно что просиходит

4)что бы успевали менятся статусы делай на каждом этапе запрсо в базу, а не бери из кэша, и можно между цензором и мутатором сделать задерку 2 сек.
было бы идеально если в мейне было нью цензор нью мутатор
 5) после цензора и мутатора так же новый экземпляр класса ОТК отдел контроля качества, сейчас в нем только 1 метод если у нас статус у сообщения mutated
меняем его на ready_to_send

6) нужно сделать стейт машину что бы нельзя было перескакивать между статусами, то есть если мы отклонили сообщение его нельзя уже отпарвить или сделать ready_to_send

--------------------------------------------------------------------24 мая
1) нужно создать метод который будет запускаться при создании новой сущность MessageItem.
2) его задача будет собрать адреса медиа файлов которые относяться к новому сообщению и сохранить их в базе.
3)  вот пример нескольких файлов   photo_23824.jpg  лежит в /home/feda/py/read-messages-from-group/media/group_1551946392/msg_23824 
где  имя группы group_1551946392 из public."groups" поле group_id,  msg_23824 это номер сообщения из public.messages 
нужно собрать списко медиафайлов(это могут быть не только картинки) пороверить есть ли они по факту в этих папках и положить массив  в  public.message_items.media_files
4) в 1 директори 1 медиа файл
5) файлы могут быть не только картинки, а все что разрешено передавать в качестве медиа в тг сообщениях
6) оформи это все в отдельный метод и сделай подробные комментарии как все работает
7) медиа может не быть тогда не записываем это в базу. иногда media_files может быть []







1. Создание таблицы groups

20250531000001_create_groups.rb
ruby

class CreateGroups < ActiveRecord::Migration[7.0]
def change
create_table :groups, id: false do |t|
t.bigint :group_id, primary_key: true
t.text :title, null: false
t.text :username
t.integer :participants_count
t.timestamp :last_updated, null: false
end
end
end

2. Создание таблицы messages

20250531000002_create_messages.rb
ruby

class CreateMessages < ActiveRecord::Migration[7.0]
def change
create_table :messages do |t|
t.bigint :message_id, null: false
t.bigint :group_id, null: false
t.bigint :grouped_id
t.timestamp :date, null: false
t.text :text, null: false
t.bigint :sender_id
t.text :sender_username
t.text :sender_first_name
t.text :sender_last_name
t.boolean :sender_is_bot, default: false
t.boolean :media, null: false
t.text :media_type
t.text :link, null: false
t.boolean :sent_status, null: false, default: false
t.timestamp :sent_at

      t.foreign_key :groups, column: :group_id, primary_key: :group_id
      t.index [:message_id, :group_id], unique: true
    end
end
end

3. Создание таблицы message_sources

20250531000003_create_message_sources.rb
ruby

class CreateMessageSources < ActiveRecord::Migration[7.0]
def change
create_table :message_sources do |t|
t.text :source_type, null: false
t.text :external_id, null: false, default: ''
t.text :name
t.text :link
t.boolean :enabled, null: false, default: true
t.timestamp :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
t.timestamp :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.index [:source_type, :external_id], unique: true
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE message_sources
          ADD CONSTRAINT valid_source_type 
          CHECK (source_type IN ('tggroup', 'vkgroup', 'email_group'))
        SQL
      end
    end
end
end

4. Создание таблицы message_items

20250531000004_create_message_items.rb
ruby

class CreateMessageItems < ActiveRecord::Migration[7.0]
def change
create_table :message_items do |t|
t.bigint :grouped_id
t.bigint :message_source_id, null: false
t.text :status, null: false, default: 'new'
t.text :processed_text, null: false, default: ''
t.jsonb :media_files, null: false, default: '[]'
t.timestamp :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
t.text :rejection_reason
t.timestamp :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.foreign_key :message_sources, column: :message_source_id
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE message_items
          ADD CONSTRAINT valid_status 
          CHECK (status IN (
            'new', 'processing', 'censored', 'censored_failed',
            'mutated', 'in_mutation', 'mutation_failed',
            'ready_to_send', 'sent', 'error'
          ))
        SQL
      end
    end
end
end

5. Создание таблицы message_item_sources

20250531000005_create_message_item_sources.rb
ruby

class CreateMessageItemSources < ActiveRecord::Migration[7.0]
def change
create_table :message_item_sources, primary_key: [:message_item_id, :message_id, :group_id] do |t|
t.bigint :message_item_id, null: false
t.bigint :message_id, null: false
t.bigint :group_id, null: false

      t.foreign_key :message_items, column: :message_item_id
    end
end
end








