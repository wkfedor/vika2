# spec/factories/message.rb

FactoryBot.define do
  factory :message do
    processed_text { "Текст с рекламой\nПиши в директ! +79940259324" }
  end
end
