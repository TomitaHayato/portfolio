FactoryBot.define do
  factory :user_tag_experience do
    association :user
    association :tag
    experience_point { 1 }
  end
end