require 'faker'

FactoryBot.define do
  factory :user do
    name                  { Faker::Name.name }
    sequence(:email)      {  |n| "sample#{n}@example.com" }
    password              { Faker::Alphanumeric.alphanumeric(number: 8) }
    password_confirmation { password }

    # passwordとpassword_confirmationが一致しないパターン
    trait :no_match_password_confirmation do
      password_confirmation { Faker::Alphanumeric.alphanumeric(number: 9) }
    end

    trait :no_attribute do
      name                  { nil }
      email                 { nil }
      password              { nil }
      password_confirmation { nil }
    end

    trait :over_name do
      name { Faker::Lorem.characters(number: 26) }
    end

    trait :for_system_spec do
      password              { 'password' }
      password_confirmation { password }
    end
  end
end
