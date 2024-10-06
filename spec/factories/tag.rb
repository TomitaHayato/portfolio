require 'faker'

# name, presence: true

FactoryBot.define do
  factory :tag do
    name { Faker::Lorem.characters(number: 10) }

    trait :no_name do
      name { nil }
    end
  end
end