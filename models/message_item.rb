# app/models/message_item.rb

# Подключаем AASM — гем для реализации state machine (машины состояний)
require 'aasm'

class MessageItem < ActiveRecord::Base
  self.table_name = "message_items"

  # Связь с источниками сообщений (например, Telegram, VK и т.д.)
  has_many :sources, class_name: "MessageItemSource", foreign_key: :message_item_id

  # Подключаем функционал AASM в модель
  include AASM

  # === Основная настройка AASM ===
  # Здесь мы определяем:
  # - Колонку, в которой хранится статус (`status`)
  # - Все допустимые состояния (статусы)
  # - Правила перехода между состояниями

  aasm column: :status do

    # === Возможные состояния (статусы) ===

    # Начальное состояние.
    # Сообщение получено, но ещё не обработано цензором или мутатором.
    state :new, initial: true

    # Обработка начата.
    # Сейчас работает цензор или мутатор.
    state :processing

    # Цензор завершил работу, и сообщение прошло проверку.
    state :censored

    # Цензор отклонил сообщение — дальнейшая обработка не нужна.
    state :censored_failed

    # Началась мутация текста.
    state :in_mutation

    # Мутация успешно выполнена.
    state :mutated

    # Мутация завершена с ошибкой.
    state :mutation_failed

    # Сообщение готово к отправке.
    state :ready_to_send

    # Сообщение успешно отправлено.
    state :sent

    # Произошла непредвиденная ошибка на любом этапе.
    state :error


    # === События и разрешённые переходы между состояниями ===

    # --- Этап 1: Начать обработку ---
    # Из: new
    # В: processing
    event :start_processing do
      transitions from: :new, to: :processing
    end

    # --- Этап 2: Цензура ---
    # Успешный проход цензуры
    event :pass_censor do
      transitions from: :processing, to: :censored
    end

    # Отказ по цензуре
    event :fail_censor do
      transitions from: :processing, to: :censored_failed
    end

    # --- Этап 3: Мутация ---
    # Начать мутацию
    event :start_mutation do
      transitions from: :censored, to: :in_mutation
    end

    # Успешная мутация
    event :succeed_mutation do
      transitions from: :in_mutation, to: :mutated
    end

    # Неудачная мутация
    event :fail_mutation do
      transitions from: :in_mutation, to: :mutation_failed
    end

    # --- Этап 4: Одобрение и отправка ---
    # Одобрить для отправки (ОТК)
    event :approve_for_sending do
      transitions from: :mutated, to: :ready_to_send
    end

    # Отправить сообщение
    event :mark_as_sent do
      transitions from: :ready_to_send, to: :sent
    end

    # --- Этап X: Обработка ошибок ---
    # Пометить как ошибочное
    event :mark_as_error do
      transitions from: %i[new processing censored in_mutation], to: :error
    end

  end
end
