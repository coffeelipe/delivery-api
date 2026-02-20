# frozen_string_literal: true
FactoryBot.define do
  factory :order do
    sequence(:id) { Faker::Internet.uuid }
    store_id { Faker::Internet.uuid }
    details { { items: [] } }
  end
end
