FactoryBot.define do
  factory :user_reward do
    association :user
    association :reward
  end
end