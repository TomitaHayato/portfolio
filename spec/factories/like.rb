FactoryBot.define do
  factory :like do
    association :user
    association :routine
  end
end