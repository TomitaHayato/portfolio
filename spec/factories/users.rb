require 'faker'

FactoryBot.define do
  factory :user do
    name                  { Faker::Name.name }
    sequence(:email)      {  |n| "sample#{n}@example.com" }
    password              { Faker::Alphanumeric.alphanumeric(number: 4) }
    password_confirmation { password }

    # passwordとpassword_confirmationが一致しないパターン
    trait :no_match_password_confirmation do
      password_confirmation { Faker::Alphanumeric.alphanumeric(number: 5) }
    end

    trait :no_attribute do
      name                  { nil }
      email                 { nil }
      password              { nil }
      password_confirmation { nil }
    end

    trait :for_system_spec do
      password              { 'password' }
      password_confirmation { password }
    end
  end
end
