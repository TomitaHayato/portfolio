require 'faker'

# validates :title, presence: true, length: { maximum: 50 }
# validates :description, length: { maximum: 500 }
# デフォルト値：　is_posted, is_active

FactoryBot.define do
  factory :routine do
    title { Faker::Lorem.characters(number: 50) }
    description { Faker::Lorem.characters(number: 500) }

    trait :no_title do
      title { nil }
    end

    trait :over_length do
      title { Faker::Lorem.characters(number: 51) }
      description { Faker::Lorem.characters(number: 501) }
    end
  end
end