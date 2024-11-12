require 'faker'
=begin
  validates :title, presence: true, length: { maximum: 25 }
  validates :estimated_time_in_second,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              message: 'は1以上の整数を入力してください'
            }

    デフォルト値：　　"estimated_time_in_second", default: 60
=end

FactoryBot.define do
  factory :task do
    title { Faker::Lorem.characters(number: 25) }
    association :routine

    trait :nil_title_estimated_time do
      title                    { nil }
      estimated_time_in_second { nil }
    end

    trait :over_title do
      title { Faker::Lorem.characters(number: 26) }
    end

    trait :zero_estimated_time do
      estimated_time_in_second { 0 }
    end
  end
end