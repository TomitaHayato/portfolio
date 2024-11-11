FactoryBot.define do
  factory :reward do
    image { File.open(Rails.root.join('public', 'image_for_test.png')) }

    trait :hajimarinoippo do
      name        { 'はじまりの一歩！' }
      condition   { 'completed_routine_1?' }
      description { 'ルーティンを1回クリアする' }
    end

    trait :wakamenoseichou do
      name        { '若芽の成長' }
      condition   { 'get_experiences_10?' }
      description { '経験値を10獲得する' }
    end

    trait :asanomorinoannnaininn do
      name        { '朝の森の案内人' } 
      condition   { 'post_routine_1?' }
      description { 'ルーティンを1つ投稿する' }
    end

    trait :chiisanatasseisha do
      name        { '小さな達成者' }
      condition   { 'completed_routines_3?' }
      description { 'ルーティンを3回クリアする' }
    end
  end
end