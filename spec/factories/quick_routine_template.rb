FactoryBot.define do
  factory :quick_routine_template do
    association :user

    trait :over_length do
      title       { Faker::Lorem.characters(number: 26) }
      description { Faker::Lorem.characters(number: 501) }
    end
  end
end