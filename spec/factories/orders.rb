# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    sequence(:id) { Faker::Internet.uuid }
    store_id { Faker::Internet.uuid }
    details { { items: [] } }
  end

  factory :status, class: Hash do
    created_at { (Time.now.to_f * 1000).to_i }
    name { Order::STATUSES[:received] }
    order_id { Faker::Internet.uuid }
    origin { 'STORE' }

    initialize_with { attributes.stringify_keys }
  end
end
