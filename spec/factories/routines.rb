require 'faker'

# validates :title, presence: true, length: { maximum: 50 }
# validates :description, length: { maximum: 500 }
# デフォルト値：　is_posted, is_active

FactoryBot.define do
  factory :routine do
    title { Faker::Lorem.characters(number: 50) }
    description { Faker::Lorem.characters(number: 500) }
    association :user

    trait :nil_title do
      title { nil }
    end

    trait :over_length do
      title { Faker::Lorem.characters(number: 51) }
      description { Faker::Lorem.characters(number: 501) }
    end

    trait :active_posted_counted do
      is_active { true }
      is_posted { true }
      completed_count { 1 }
      copied_count { 1 }
    end
  end
end